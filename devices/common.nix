# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    inputs.home-manager.nixosModules.home-manager
    outputs.nixosModules.agenix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

    ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };

  users.users = {
    xavier = {
      initialHashedPassword = "*";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApzCHCSQflPkh7oPjpQ+V9MAFR5fvlE/1PAvMoYoSN3 xavier@gurb"
      ];

      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
    };
  };

  age = {
    identityPaths = [
      "/tmp/master-key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secretsDir = "/run/agenix";

    secrets = {
      secret_as-xvi_ssh_key = {
        file = ../secrets/secret_as-xvi_ssh_key.age;
        owner = "xavier";
        group = "users";
        mode = "0600";
      };
      secret_xvi_ssh_key = {
        file = ../secrets/secret_xvi_ssh_key.age;
        owner = "xavier";
        group = "users";
        mode = "0600";
      };
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  programs.git.enable = true;

  programs.nix-ld.enable = true;

  programs.ssh.startAgent = true;

  # Enable docker system-wide for all devices
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.home-manager.packages.${pkgs.system}.default
    wget
    htop
    vim
    curl
    killall
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
      inherit (config.age) secrets;
    };

    users = {
      # Import your home-manager configuration
      xavier = import (../home-manager + "/xavier-at-${config.networking.hostName}.nix");
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
