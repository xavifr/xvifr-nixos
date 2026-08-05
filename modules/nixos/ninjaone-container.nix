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
#     installerDeb = pkgs.fetchurl {
#       url = "https://eu.ninjarmm.com/ws/api/v2/generic-installer/NinjaOneAgent-x86_64.deb";
#       hash = "sha256-...";
#     };
#     baseUrl = "https://eu.ninjarmm.com";
#     # clientUIDFile = config.age.secrets.ninjaone-client-uid.path; # only if your org requires one
#   };
#
# Notes / caveats:
# - installerDeb: some NinjaOne instances hand out a truly generic installer
#   (no org token baked into the URL/binary) and rely on network-level
#   auto-approval (a discovery/supervisor agent already on your LAN) to
#   assign new devices to the right org -- in that case just pkgs.fetchurl
#   the generic-installer link above. Other instances generate an
#   account-tied installer from the console (Administration -> Apps ->
#   Installer) that can't be fetched generically -- in that case pass a
#   local path to that download instead.
# - clientUIDFile (optional) points at a file containing the raw clientUID
#   (e.g. an agenix/sops-nix decrypted secret under /run/agenix), only
#   needed if your NinjaOne instance requires manual registration rather
#   than auto-approval. It's read at activation time via `cat`, so the
#   value itself never lands in the world-readable /nix/store -- only the
#   runtime path does. Leave unset if your org auto-approves new agents.
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
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXtst
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libxcb
      xorg.libXau
      xorg.libXdmcp
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

  agentRuntimePath = lib.makeBinPath (
    with pkgs;
    [
      coreutils-full
      bash
      parted
      procps
      dmidecode
      numactl
      readline
      ncurses
      util-linux
      nettools
      networkmanager
      policycoreutils
      file
      python3
      which
      fakeLdconfig
    ]
  );

  ninjaOneImage = pkgs.dockerTools.buildLayeredImage {
    name = "ninjaone-agent";
    tag = "latest";
    contents = [
      pkgs.bash
      pkgs.coreutils
      pkgs.cacert
    ];

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
      type = lib.types.str;
      example = "https://app.ninjarmm.com";
      description = "NinjaOne base URL for your instance.";
    };

    clientUIDFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file (e.g. an agenix-decrypted secret) containing the NinjaOne clientUID / install token. Leave null if your NinjaOne instance auto-approves new agents (e.g. via a network discovery/supervisor agent) instead of requiring one.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 443;
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
    system.activationScripts.ninjaone-machine-id = ''
      if [ ! -f ${cfg.stateDir}/machine-id ]; then
        ${pkgs.coreutils}/bin/cat /proc/sys/kernel/random/uuid \
          | tr -d '-' > ${cfg.stateDir}/machine-id
      fi
    '';

    # Written on every activation, kept out of the container image itself so
    # the .deb-derived image stays reusable/shareable without your token in it.
    # clientUIDFile (when set) is read at runtime, not Nix-interpolated, so
    # the secret value itself never gets embedded into the store-path
    # activation script -- only its runtime path does.
    system.activationScripts.ninjaone-server-conf = ''
      mkdir -p ${cfg.stateDir}/config
      cat > ${cfg.stateDir}/config/server.conf <<EOF
      [General]
      ${lib.optionalString (cfg.clientUIDFile != null) "ClientUID=$(cat ${cfg.clientUIDFile})"}
      Host=${cfg.baseUrl}
      Port=${toString cfg.port}
      DivisionUID=
      NodeUid=
      EOF
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
      ];

      extraOptions = [
        "--cap-add=NET_RAW"
        "--cap-add=NET_ADMIN"
      ]
      ++ lib.optionals cfg.hostNetworking [
        "--network=host"
        "--pid=host"
      ];
    };
  };
}
