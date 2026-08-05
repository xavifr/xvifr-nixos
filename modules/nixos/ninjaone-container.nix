# modules/ninjaone-container.nix
#
# Runs the NinjaOne Linux agent inside a container image built entirely from
# Nix derivations (no Debian base pulled from the network), managed by
# NixOS's `virtualisation.oci-containers` (podman backend). Everything is
# declared here -- no docker-compose file, no imperative `docker run`.
#
# Usage in configuration.nix / flake:
#
#   imports = [ ./modules/ninjaone-container.nix ];
#   services.ninjaone-container = {
#     enable = true;
#     installerDeb = /root/secrets/ninjaone-agent.deb; # see note below
#   };
#
# Notes / caveats:
# - installerDeb: the account-tied installer you download from your NinjaOne
#   console (Administration -> Apps -> Installer) already has a working
#   config/server.conf and config/agent.conf baked in (real ClientUID/Host,
#   set at download time) -- do NOT regenerate/overwrite those, just seed the
#   persistent state dir from them once (see ninjaone-server-conf below).
#   A *generic*, non-account-tied installer instead ships those files with
#   literal placeholders ("no-token"/"no-host") that must be overridden via
#   baseUrl/clientUIDFile below.
# - baseUrl/clientUIDFile/port (all optional, default null/443) only exist to
#   patch a generic installer's placeholder config. Leave them unset for an
#   account-tied installer -- setting them would overwrite values NinjaOne
#   already got right. clientUIDFile is read at activation time via `cat`
#   (e.g. from an agenix-decrypted secret), so the value itself never lands
#   in the world-readable /nix/store -- only its runtime path does.
# - --network=host and --pid=host are set so the agent can see real host
#   network/process info rather than just the container's. Drop them if you
#   want tighter isolation and are OK with container-scoped telemetry only.
# - First boot: the machine-id activation script generates a stable ID once
#   and persists it under stateDir so container restarts/recreations don't
#   trigger the duplicate-device bug seen on bare-metal NixOS installs.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ninjaone-container;

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
  # NinjaOne's agent uses to fingerprint the installed `top` (confirmed:
  # `top -v` exits 1 with "invalid option -- 'v'" otherwise). Must come
  # before procps in agentTools so this shadows the real `top` on PATH.
  topCompat = pkgs.writeShellScriptBin "top" ''
    if [ "$1" = "-v" ]; then
      exec ${pkgs.procps}/bin/top --version
    fi
    exec ${pkgs.procps}/bin/top "$@"
  '';

  # Single source of truth for what's on PATH inside the container --
  # also fed into ninjaOneImage's `contents` below, so nothing ends up
  # referenced on PATH without its actual binary present in the image.
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
      gawk # awk -- confirmed needed: agent runs `awk -F: '{ print $1 }' /etc/passwd`
      lsof # confirmed needed: agent runs `lsof -i -n -P`
      gnugrep # grep, egrep, fgrep
    ];

  agentRuntimePath = lib.makeBinPath agentTools;

  ninjaOneImage = pkgs.dockerTools.buildLayeredImage {
    name = "ninjaone-agent";
    tag = "latest";
    contents = agentTools;

    extraCommands = ''
      mkdir -p opt
      cp -r ${ninjaOneAgent}/NinjaRMMAgent opt/NinjaRMMAgent
      chmod -R u+w opt/NinjaRMMAgent
      mkdir -p opt/NinjaRMMAgent/programfiles/config
      mkdir -p opt/NinjaRMMAgent/programdata/storage
      mkdir -p opt/NinjaRMMAgent/programdata/download
    '';

    config = {
      WorkingDir = "/opt/NinjaRMMAgent/programfiles";
      Entrypoint = [
        "${pkgs.bash}/bin/bash"
        "-c"
        "cd /opt/NinjaRMMAgent/programfiles && exec ./ninjarmm-linagent"
      ];
      Env = [
        "LC_ALL=C"
        # Without this, ninjarmm-linagent daemonizes itself (forks a
        # detached child and exits) -- fine for a traditional init system,
        # fatal in a container, since the exiting process is PID 1. Matches
        # the Environment= line in the .deb's own bundled
        # tmp/ninja-startup/ninjarmm-agent.service (Type=simple).
        "DAEMON_RUN=1"
        "NINJA_AGENT_HOME=/opt/NinjaRMMAgent"
        "PATH=${agentRuntimePath}:/opt/NinjaRMMAgent/programfiles"
        "LD_LIBRARY_PATH=/opt/NinjaRMMAgent/programfiles"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  };

in
{
  options.services.ninjaone-container = {
    enable = lib.mkEnableOption "NinjaOne RMM agent (containerized, podman)";

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

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ninjaone-container";
      description = "Host path for persistent agent state (machine-id, config, storage).";
    };

    hostNetworking = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use --network=host and --pid=host so the agent reports real host telemetry.";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0700 root root -"
      "d ${cfg.stateDir}/config 0700 root root -"
      "d ${cfg.stateDir}/storage 0700 root root -"
      "d ${cfg.stateDir}/download 0700 root root -"
    ];

    # Stable machine-id, generated once, persisted, so container recreation
    # doesn't re-derive a new ID and duplicate the device in the console.
    # mkdir here rather than relying on systemd.tmpfiles.rules above: those
    # are applied by systemd-tmpfiles-resetup.service, a separate unit that
    # isn't guaranteed to have run yet during this activation script.
    system.activationScripts.ninjaone-machine-id = ''
      mkdir -p ${cfg.stateDir}
      if [ ! -f ${cfg.stateDir}/machine-id ]; then
        ${pkgs.coreutils}/bin/cat /proc/sys/kernel/random/uuid \
          | tr -d '-' > ${cfg.stateDir}/machine-id
      fi
    '';

    # Seeded ONCE from the installer's own bundled config (which, for an
    # account-tied installer, already has a real working ClientUID/Host set
    # by NinjaOne at download time) -- never overwritten afterwards, so the
    # agent's own runtime updates to these files (e.g. NodeUid after first
    # check-in) survive rebuilds/restarts. baseUrl/clientUIDFile/port, when
    # set, patch the seeded file in place (for a generic installer's
    # placeholder values); clientUIDFile is read at activation time via
    # `cat`, so the secret value itself never lands in the world-readable
    # /nix/store -- only its runtime path does.
    system.activationScripts.ninjaone-server-conf = ''
      mkdir -p ${cfg.stateDir}/config
      if [ ! -f ${cfg.stateDir}/config/server.conf ]; then
        install -m 0600 ${ninjaOneAgent}/NinjaRMMAgent/programfiles/config/server.conf ${cfg.stateDir}/config/server.conf
      fi
      if [ ! -f ${cfg.stateDir}/config/agent.conf ]; then
        install -m 0600 ${ninjaOneAgent}/NinjaRMMAgent/programfiles/config/agent.conf ${cfg.stateDir}/config/agent.conf
      fi
      ${lib.optionalString (cfg.baseUrl != null) ''
        sed -i "s|^Host=.*|Host=${cfg.baseUrl}|" ${cfg.stateDir}/config/server.conf
      ''}
      ${lib.optionalString (cfg.port != null) ''
        sed -i "s|^Port=.*|Port=${toString cfg.port}|" ${cfg.stateDir}/config/server.conf
      ''}
      ${lib.optionalString (cfg.clientUIDFile != null) ''
        sed -i "s|^ClientUID=.*|ClientUID=$(cat ${cfg.clientUIDFile})|" ${cfg.stateDir}/config/server.conf
      ''}
    '';

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.ninjaone = {
      imageFile = ninjaOneImage;
      image = "ninjaone-agent:latest";
      autoStart = true;

      volumes = [
        "${cfg.stateDir}/machine-id:/etc/machine-id:ro"
        "${cfg.stateDir}/config:/opt/NinjaRMMAgent/programfiles/config"
        "${cfg.stateDir}/storage:/opt/NinjaRMMAgent/programdata/storage"
        "${cfg.stateDir}/download:/opt/NinjaRMMAgent/programdata/download"
        # Real host visibility for inventory/monitoring (disks, hardware,
        # process list) -- the container's own default /proc, /dev, /sys
        # are namespaced/restricted and don't show the true host state.
        "/proc:/proc"
        # rslave: plain bind only shows /dev's own top-level entries, not
        # nested mounts like /dev/shm (confirmed missing without this).
        "/dev:/dev:rslave"
        "/sys:/sys"
        # Shared under --network=host anyway; agent expects it to exist.
        "/etc/hosts:/etc/hosts:ro"
        # nmcli talks to the host's NetworkManager over D-Bus -- without
        # this it can print --version but can't list/control connections.
        "/run/dbus:/run/dbus"
      ];

      extraOptions = [
        "--cap-add=NET_RAW"
        "--cap-add=NET_ADMIN"
        # Bind privileged (<1024) ports and send to broadcast/multicast
        # addresses -- rounds out NET_RAW/NET_ADMIN for full network
        # visibility/control parity with a native install.
        "--cap-add=NET_BIND_SERVICE"
        "--cap-add=NET_BROADCAST"
        # Needed to read /dev/mem for SMBIOS/BIOS data (confirmed: EPERM
        # without it, even with the device node visible via the /dev mount)
        # and for device-mapper ioctls (confirmed: `parted` failed on
        # /dev/mapper/control without SYS_ADMIN).
        "--cap-add=SYS_RAWIO"
        "--cap-add=SYS_ADMIN"
        # The /dev bind mount above makes device nodes *visible*, but
        # Podman's device cgroup allow-list separately blocks actually
        # opening most of them (confirmed: fdisk/parted silently found zero
        # disks, no error, despite /dev/nvme0n1 etc. being right there).
        # Rather than chase one --device=/dev/X entry per disk/device type,
        # allow the whole block+char device classes -- consistent with the
        # capabilities above already granting near-host-equivalent trust.
        "--device-cgroup-rule=b *:* rwm"
        "--device-cgroup-rule=c *:* rwm"
      ]
      ++ lib.optionals cfg.hostNetworking [
        "--network=host"
        "--pid=host"
      ];
    };
  };
}
