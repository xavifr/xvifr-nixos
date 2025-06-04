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
}:
{
  imports = [
        outputs.homeManagerModules.agenix
  ];

  # chromium is global
  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "haipckejfdppjfblgondaakgckohcihp" # milk cookie manager
      # "cimiefiiaegbelhefglklhhakcgmhkai" # plasma integration
    ];
  };

  # everyone should have cursor installed and setup
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    profiles.default = {
      userSettings = {
        "editor.cursorBlinking" = "smooth";
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "window.commandCenter" = true;
        "workbench.colorTheme" = "Cursor Dark High Contrast";
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
  
  programs.git = {
    enable = lib.mkDefault true;
    userName = lib.mkDefault "Xavier Franquet";
    userEmail = lib.mkDefault "xavier@franquet.es";
  };
  
  # agenix for everyone
  modules.agenix.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}