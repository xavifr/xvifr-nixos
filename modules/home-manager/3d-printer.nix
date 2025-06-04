{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.as-dev;
in
{
  options.modules.kubernetes = {
    enable = mkEnableOption "3D Printer tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cura-appimage
      blender
      # extra slicer?
    ];


    # Optional: Add cura profiles
    # xdg.configFile."cura/files".source = ./kubectl-config;
  };
}
