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
    outputs.homeManagerModules.as-dev
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
      "cimiefiiaegbelhefglklhhakcgmhkai" # plasma integration
    ];
  };

  modules.agenix.enable = true;

  modules.kubernetes.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
