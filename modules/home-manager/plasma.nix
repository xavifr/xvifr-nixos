{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.plasma;
in
{
  options.modules.plasma = {
    enable = mkEnableOption "KDE Plasma customization";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
    ];

    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        command_timeout = 1300;
        scan_timeout = 50;
        format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$golang$python$kubernetes[](fg:#212736 bg:#1d2230)$time[](fg:#1d2230)\n$character";
        directory = {
          style = "fg:#e3e5e5 bg:#769ff0";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        git_branch = {
          symbol = "";
          style = "bg:#394260";
          format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
        };

        git_status = {
          style = "bg:#394260";
          format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        python = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        time = {
          disabled = false; # Nix boolean value
          time_format = "%R";
          style = "bg:#1d2230";
          format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
        };
        character = {
          success_symbol = "[](bold green) ";
          error_symbol = "[✗](bold red) ";
        };
      };
    };

    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        background-opacity = 0.95;
        background-blur = 40;
        shell-integration = "fish";
        command = "fish";
        keybind = [
          "ctrl+backspace=text:\\x15"
        ];
      };
    };

    programs.fish = {
      enable = true;
    };
  };
}
