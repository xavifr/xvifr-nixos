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
    outputs.homeManagerModules.plasma
    outputs.homeManagerModules.dev
    outputs.homeManagerModules.agenix
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
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "haipckejfdppjfblgondaakgckohcihp" # milk cookie manager
      # "cimiefiiaegbelhefglklhhakcgmhkai" # plasma integration
    ];
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfigOverride = ''
      Host p.github.com
        Hostname github.com
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User git
        Port 22

      Host *
        IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
        ServerAliveCountMax 3
        HashKnownHosts no

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
