{
  config,
  lib,
  ...
}:
{
  options = {
    modules.unstable = {
      enable = lib.mkEnableOption "Enable nixpkgs-unstable";
    };
  };

  config = lib.mkIf config.modules.unstable.enable {
    nixpkgs.config = {
      packageOverrides = pkgs: {
        unstable = import <nixpkgs-unstable> {
          config = config.nixpkgs.config;
        };
      };
    };
  };
}
