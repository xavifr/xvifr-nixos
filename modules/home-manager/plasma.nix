{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.plasma;

  # Fetch plasma-manager
  plasma-manager = builtins.fetchTarball {
    url = "https://github.com/pjones/plasma-manager/archive/b7697abe89967839b273a863a3805345ea54ab56.tar.gz";
    sha256 = "05gw226063jbklfgcyr01a04278v7shn8a4imjg47rdzgsqf68fn";
  };
in
{
  imports = [
    (plasma-manager + "/modules")
  ];

  # Enable plasma-manager
  programs.plasma = {
    enable = true;

    configFile.kdeglobals.General = {
      TerminalApplication = "kitty";
      TerminalService = "kitty.desktop";
    };

    # Workspace settings
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      cursor.theme = "breeze_cursors";
      iconTheme = "breeze-dark";
      wallpaper = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/KDE/plasma-workspace-wallpapers/eb98b8b6a9e2a22a9071bb72ab3f9771e08033ce/ScarletTree/contents/images_dark/5120x2880.png";
        sha256 = "0aj1gm1c6n9vj8gni4dgq9h1d8rj36h9qwy8r4l7wf0wm3xxzn13";
      };
    };

    kwin = {
      virtualDesktops = {
        rows = 2;
        number = 4;
        names = [
          "Desktop 1"
          "Desktop 2"
          "Desktop 3"
          "Personal"
        ];
      };
    };

    input.keyboard = {
      numlockOnStartup = "on";
    };

    # Fonts configuration
    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Hack";
        pointSize = 10;
      };
    };

    # Shortcuts
    shortcuts = {
      "services/kitty.desktop" = {
        "_launch" = [
          "Ctrl+Alt+T"
        ];
      };
      "services/org.kde.spectacle.desktop" = {
        "RectangularRegionScreenShot" = [
          "Print"
          "Meta+Shift+S"
        ];
      };
    };

    # Panel configuration
    panels = [
      {
        location = "bottom";
        screen = 0;
        widgets = [
          "org.kde.plasma.kickoff"
          {
            name = "org.kde.plasma.pager";
            config = {
              General.showOnlyCurrentScreen = true;
            };
          }
          {
            name = "org.kde.plasma.taskmanager";
            config = {
              General = {
                middleClickAction = "ToggleGrouping";
                groupingStrategy = 1;
                iconSpacing = 0;
                showOnlyCurrentScreen = true;
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "org.kde.plasma.systemtray";
            config = {
              icons.spacing = "small";
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                firstDayOfWeek = "monday";
                showWeekNumbers = true;
                showSeconds = "Always";
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
      {
        location = "bottom";
        screen = 1;
        widgets = [
          "org.kde.plasma.kickoff"
          {
            name = "org.kde.plasma.pager";
            config = {
              General.showOnlyCurrentScreen = true;
            };
          }
          {
            name = "org.kde.plasma.taskmanager";
            config = {
              General = {
                middleClickAction = "ToggleGrouping";
                groupingStrategy = 1;
                iconSpacing = 0;
                showOnlyCurrentScreen = true;
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "org.kde.plasma.systemtray";
            config = {
              icons.spacing = "small";
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                firstDayOfWeek = "monday";
                showWeekNumbers = true;
                showSeconds = "Always";
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
      {
        location = "bottom";
        screen = 2;
        widgets = [
          "org.kde.plasma.kickoff"
          {
            name = "org.kde.plasma.pager";
            config = {
              General.showOnlyCurrentScreen = true;
            };
          }
          {
            name = "org.kde.plasma.taskmanager";
            config = {
              General = {
                middleClickAction = "ToggleGrouping";
                groupingStrategy = 1;
                iconSpacing = 0;
                showOnlyCurrentScreen = true;
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "org.kde.plasma.systemtray";
            config = {
              icons.spacing = "small";
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                firstDayOfWeek = "monday";
                showWeekNumbers = true;
                showSeconds = "Always";
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # Window rules
    window-rules = [
    ];
  };

  # Additional packages for Plasma
  home.packages = with pkgs; [
    xdg-desktop-portal-wlr
    nil
  ];

}
