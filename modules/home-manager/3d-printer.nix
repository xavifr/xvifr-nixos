{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.modules.as-dev;
in {
  options.modules.kubernetes = {
    enable = mkEnableOption "3D Printer tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # ultimaker cura
      # blender
      # slicer?
    ];

    # Optional: Add kubectl configuration
    # xdg.configFile."kubectl/config".source = ./kubectl-config;
  };
} 