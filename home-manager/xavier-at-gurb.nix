# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  secrets,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.kubernetes
    outputs.homeManagerModules.plasma
    outputs.homeManagerModules.dev
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "xavier";
    homeDirectory = "/home/xavier";
  };

  programs.home-manager.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    chromium


    (pkgs.callPackage "${builtins.fetchTarball {
      url = "https://github.com/ryantm/agenix/archive/main.tar.gz";
      sha256 = "0ngkhf7qamibhbl9z1dryzscd36y4fz1m1h6fb2z6fylw0b8029p";
    }}/pkgs/agenix.nix" {})
  ];

  modules.kubernetes.enable = true;


  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host p.github.com
        Hostname github.com
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User git
        Port 22

      IdentityFile ${secrets.secret_as-xvi_ssh_key.path}

    '';
    
  };


  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Xavier Franquet";
    userEmail = "xavier@franquet.es";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    profiles.default = {
      userSettings = {
        "editor.cursorBlinking" = "smooth";
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "window.commandCenter"= true;
        "workbench.colorTheme"= "Cursor Dark High Contrast";
      };
      extensions = with pkgs.vscode-extensions; [
        golang.go
        matangover.mypy
        redhat.vscode-yaml
        charliermarsh.ruff
        ms-python.python
        eamodio.gitlens
        ms-azuretools.vscode-docker
        bbenoist.nix

      ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
