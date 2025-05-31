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
    
    wallpaper = mkOption {
      type = types.path;
      description = "Path to the wallpaper image";
      default = null;
    };

    panels = {
      top = mkOption {
        type = types.bool;
        default = true;
        description = "Enable top panel";
      };
      bottom = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bottom panel";
      };
    };

    theme = {
      name = mkOption {
        type = types.str;
        default = "Breeze";
        description = "Plasma theme name";
      };
      colorScheme = mkOption {
        type = types.str;
        default = "BreezeLight";
        description = "Color scheme name";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable KDE Plasma integration
    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5.qtgraphicaleffects
    ];

    # Configure KDE Plasma
    xdg.configFile = {
      # Plasma configuration
      "plasma-org.kde.plasma.desktop-appletsrc" = let
        panelConfig = location: ''
          [Containments][${location}]
          ItemsGeometries=Applet-1:0,0,0,0;Applet-2:0,0,0,0;
          lastScreen=0
          location=${location}
          plugin=org.kde.panel
          type=2
        '';
      in {
        text = ''
          ${optionalString cfg.panels.top (panelConfig "4")}
          ${optionalString cfg.panels.bottom (panelConfig "2")}
        '';
      };

      # KDE configuration
      "kdeglobals" = {
        text = ''
          [General]
          ColorScheme=${cfg.theme.colorScheme}
          Name=${cfg.theme.name}
          widgetStyle=Breeze
        '';
      };
    } // (if cfg.wallpaper != null then {
      "plasmarc" = {
        text = ''
          [Theme]
          name=${cfg.theme.name}
          wallpaper=${cfg.wallpaper}
        '';
      };
    } else {});
  };
} 