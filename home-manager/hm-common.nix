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
    outputs.homeManagerModules.uping
  ];

  home.packages = with pkgs; [
    bitwarden-desktop
    nixfmt-rfc-style
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

  # agenix for everyone
  modules.agenix.enable = true;

  # uping for everyone
  modules.uping.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
