# modules/ninjaone-systemd.nix
#
# Runs the NinjaOne Linux agent as a plain systemd service directly on the
# host -- no container, no podman. This is the same Nix-patched agent binary
# as ./ninjaone-container.nix (autoPatchelf fixes its dynamic linking), just
# launched the way NinjaOne's own bundled unit does (see
# tmp/ninja-startup/ninjarmm-agent.service inside the .deb): Type=simple,
# DAEMON_RUN=1, running as root with no sandboxing.
#
# Use this instead of ninjaone-container.nix if the containerized version
# keeps needing new bind mounts/capabilities for host paths the agent
# hardcodes (/, /etc/hosts, /proc/acpi, /dev/mem, ...) -- native execution
# gets all of that for free, since it just *is* the host.
#
# Usage in configuration.nix / flake:
#
#   imports = [ ./modules/ninjaone-systemd.nix ];
#   services.ninjaone-agent = {
#     enable = true;
#     installerDeb = /root/secrets/ninjaone-agent.deb; # see note below
#   };
#
# Notes / caveats:
# - installerDeb: the account-tied installer you download from your NinjaOne
#   console (Administration -> Apps -> Installer) already has a working
#   config/server.conf and config/agent.conf baked in (real ClientUID/Host,
#   set at download time) -- do NOT regenerate/overwrite those, just seed
#   them into place once (see the activation script below). A *generic*,
#   non-account-tied installer instead ships those files with literal
#   placeholders ("no-token"/"no-host") that must be overridden via
#   baseUrl/clientUIDFile below.
# - baseUrl/clientUIDFile/port (all optional, default null/443) only exist to
#   patch a generic installer's placeholder config. Leave them unset for an
#   account-tied installer. clientUIDFile is read at activation time via
#   `cat` (e.g. from an agenix-decrypted secret), so the value itself never
#   lands in the world-readable /nix/store -- only its runtime path does.
# - The agent is installed to the real /opt/NinjaRMMAgent (not configurable):
#   NinjaOne's own binary/unit hardcode this path in places, so relocating it
#   is more likely to surface new bugs than avoid them.
# - No machine-id workaround needed here (unlike the container version) --
#   native execution just uses the host's own real /etc/machine-id.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ninjaone-agent;

  ninjaOneAgent = pkgs.stdenv.mkDerivation {
    pname = "ninjaone-agent";
    version = "unpackaged";
    src = cfg.installerDeb;

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.autoPatchelfHook
    ];
    buildInputs = with pkgs; [
      glibc
      gcc-unwrapped.lib
      libGL
      mesa
      libx11
      libxext
      libxrender
      libxtst
      libxinerama
      libxrandr
      libxcursor
      libxi
      libxscrnsaver
      libxcomposite
      libxdamage
      libxfixes
      libxcb
      libxau
      libxdmcp
      libxkbcommon
      util-linux
      openssl
      numactl
      readline
      ncurses
      acl
      gmp
      attr
    ];

    unpackPhase = ''
      mkdir extract
      dpkg-deb -x "$src" extract
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -r extract/opt/NinjaRMMAgent "$out"/NinjaRMMAgent
      find "$out" -type f \( -name "ninjarmm-*" -o -name "njbar" \) -exec chmod +x {} \;
    '';

    dontStrip = true;
  };

  fakeLdconfig = pkgs.writeShellScriptBin "ldconfig" "exit 0";

  # nixpkgs' procps `top` only accepts `--version`, not the `-v` alias
  # NinjaOne's agent uses to fingerprint the installed `top` (confirmed on
  # the container version: `top -v` exits 1 with "invalid option -- 'v'").
  # Must come before procps in agentTools so this shadows the real `top`.
  topCompat = pkgs.writeShellScriptBin "top" ''
    if [ "$1" = "-v" ]; then
      exec ${pkgs.procps}/bin/top --version
    fi
    exec ${pkgs.procps}/bin/top "$@"
  '';

  # Same toolset confirmed needed while debugging the container version --
  # the agent binary is identical, so its dependencies are too.
  agentTools =
    with pkgs;
    [
      coreutils-full
      bash
      parted # parted, partprobe
      topCompat # must precede procps so its `top` shim wins on PATH
      procps # pgrep, top (shimmed above), ps, etc.
      dmidecode
      numactl
      readline
      ncurses
      util-linux # fdisk, lsblk, mount, etc.
      nettools
      networkmanager # nmcli
      iproute2 # ip, ss, tc, etc.
      policycoreutils
      file
      python3
      which
      fakeLdconfig
      cacert
      gawk # awk
      lsof
      rsync
      gnugrep # grep, egrep, fgrep -- the `path`/`environment.PATH` fix
      # below (mkForce) fully replaces the systemd default PATH, which
      # otherwise would have included grep/sed/find for free.
    ];

  installDir = "/opt/NinjaRMMAgent";

in
{
  options.services.ninjaone-agent = {
    enable = lib.mkEnableOption "NinjaOne RMM agent (native systemd service)";

    installerDeb = lib.mkOption {
      type = lib.types.path;
      description = "Path to your org's NinjaOne Linux agent .deb installer.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "agent-eu-central.ninjarmm.com";
      description = "Override the agent check-in host. Only needed for a generic installer whose bundled server.conf has a placeholder Host; an account-tied installer already has the right value baked in.";
    };

    clientUIDFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file (e.g. an agenix-decrypted secret) containing the NinjaOne clientUID. Only needed to patch a generic installer's placeholder ClientUID; an account-tied installer already has the right value baked in.";
    };

    port = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Override the agent check-in port. Only needed to patch a generic installer's placeholder Port.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Program binaries/libs are re-synced from the Nix store on every
    # activation (so `nixos-rebuild switch` picks up a new installerDeb),
    # but config/ is deliberately excluded and seeded only once -- same
    # "seed, don't overwrite" reasoning as ninjaone-container.nix, so the
    # agent's own runtime updates to server.conf survive rebuilds.
    system.activationScripts.ninjaone-agent-install = ''
      mkdir -p ${installDir}/programfiles
      ${pkgs.rsync}/bin/rsync -a --delete --exclude=config \
        ${ninjaOneAgent}/NinjaRMMAgent/programfiles/ ${installDir}/programfiles/
      chmod -R u+w ${installDir}/programfiles

      mkdir -p ${installDir}/programfiles/config
      if [ ! -f ${installDir}/programfiles/config/server.conf ]; then
        install -m 0600 ${ninjaOneAgent}/NinjaRMMAgent/programfiles/config/server.conf ${installDir}/programfiles/config/server.conf
      fi
      if [ ! -f ${installDir}/programfiles/config/agent.conf ]; then
        install -m 0600 ${ninjaOneAgent}/NinjaRMMAgent/programfiles/config/agent.conf ${installDir}/programfiles/config/agent.conf
      fi
      ${lib.optionalString (cfg.baseUrl != null) ''
        sed -i "s|^Host=.*|Host=${cfg.baseUrl}|" ${installDir}/programfiles/config/server.conf
      ''}
      ${lib.optionalString (cfg.port != null) ''
        sed -i "s|^Port=.*|Port=${toString cfg.port}|" ${installDir}/programfiles/config/server.conf
      ''}
      ${lib.optionalString (cfg.clientUIDFile != null) ''
        sed -i "s|^ClientUID=.*|ClientUID=$(cat ${cfg.clientUIDFile})|" ${installDir}/programfiles/config/server.conf
      ''}

      mkdir -p ${installDir}/programdata/{storage,download,logs,jsonoutput,jsoninput}
      chmod -R u+w ${installDir}/programdata
    '';

    systemd.services.ninjaone-agent = {
      description = "NinjaOne RMM Agent";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        LC_ALL = "C";
        # Without this, ninjarmm-linagent daemonizes itself (forks a
        # detached child and exits) instead of staying in the foreground --
        # matches the Environment= line in the .deb's own bundled
        # tmp/ninja-startup/ninjarmm-agent.service (Type=simple).
        DAEMON_RUN = "1";
        NINJA_AGENT_HOME = installDir;
        # mkForce: the systemd module also contributes a same-priority
        # baseline PATH for every unit (confirmed via eval-time "conflicting
        # definition values" without this), so ours needs to win outright
        # rather than merge with it.
        PATH = lib.mkForce "${lib.makeBinPath agentTools}:${installDir}/programfiles";
        LD_LIBRARY_PATH = "${installDir}/programfiles";
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      # Deliberately no sandboxing directives (ProtectSystem, PrivateDevices,
      # etc.) -- the whole point of the native version is unrestricted host
      # access. Matches NinjaOne's own bundled unit file exactly otherwise.
      # In particular, no explicit --cap-add=NET_RAW/NET_ADMIN/etc or D-Bus
      # bind mount is needed here the way ninjaone-container.nix requires:
      # running as root with no CapabilityBoundingSet restriction already
      # has the full capability set, and running directly on the host means
      # it's already talking to the real system D-Bus/NetworkManager.
      serviceConfig = {
        Type = "simple";
        User = "root";
        WorkingDirectory = "${installDir}/programfiles";
        ExecStart = "${installDir}/programfiles/ninjarmm-linagent";
        Restart = "always";
        RestartSec = 5;
        TimeoutStartSec = 10;
        TimeoutStopSec = 90;
      };
    };
  };
}
