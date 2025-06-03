{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.modules.plasma;
in {
  options.modules.plasma = {
    enable = mkEnableOption "KDE Plasma customization";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
    ];
  };
} 