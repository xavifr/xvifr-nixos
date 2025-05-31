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

    force = mkOption {
      type = types.bool;
      default = false;
      description = "Force overwrite existing KDE configuration files";
    };
  };

  config = mkIf cfg.enable {
    # Enable KDE Plasma integration
    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qttools
    ];

    warnings = mkIf (!cfg.force) [
      "KDE Plasma configuration files will not be overwritten. Set modules.plasma.force = true to override this."
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
        force = cfg.force;
      };

      # KDE configuration
      "kdeglobals" = {
        text = ''
          [General]
          ColorScheme=${cfg.theme.colorScheme}
          Name=${cfg.theme.name}
          widgetStyle=Breeze
        '';
        force = cfg.force;
      };
    } // (if cfg.wallpaper != null then {
      "plasmarc" = {
        text = ''
          [Theme]
          name=${cfg.theme.name}
          wallpaper=${cfg.wallpaper}
        '';
        force = cfg.force;
      };
    } else {});

    # Script to apply Plasma changes
    home.activation.applyPlasmaChanges = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -n "$DISPLAY" ]; then
        echo "Applying Plasma changes..."
        ${pkgs.libsForQt5.qt5.qttools}/bin/qdbus org.kde.KWin /KWin reconfigure
        ${pkgs.libsForQt5.qt5.qttools}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
          var allDesktops = desktops();
          for (i=0; i<allDesktops.length; i++) {
            d = allDesktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
            d.writeConfig("Image", "${if cfg.wallpaper != null then cfg.wallpaper else ""}");
          }
        '
        ${pkgs.libsForQt5.qt5.qttools}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentLayout
        echo "Plasma changes applied!"
      else
        echo "No display detected, skipping Plasma changes"
      fi
    '';
  };
} 