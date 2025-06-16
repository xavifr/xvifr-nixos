{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.ghosttyX;

  # Fetch the Ghostty flake
  ghosttyFlake = builtins.getFlake "github:ghostty-org/ghostty/76a3612195bb3d67e67a1e824fb3cbdb4d339735";

  # Get the package from the flake
  ghosttyPackage = ghosttyFlake.packages.${pkgs.system}.default;
in
{
  options.programs.ghosttyX = {
    enable = mkEnableOption "Ghostty terminal emulator";

    package = mkOption {
      type = types.package;
      default = ghosttyPackage;
      description = "The Ghostty package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Ghostty configuration settings";
      example = {
        theme = "dracula";
        font-family = "JetBrains Mono";
        font-size = 12;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Create config file if settings are provided
    home.file.".config/ghostty/config" = mkIf (cfg.settings != { }) {
      text = concatStringsSep "\n" (
        mapAttrsToList (name: value: "${name} = ${toString value}") cfg.settings
      );
    };
  };
}
