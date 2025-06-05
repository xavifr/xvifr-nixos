{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;

let
  cfg = config.modules.uping;
in
{
  options.modules.uping = {
    enable = mkEnableOption "Uping";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inputs.uping.packages.${pkgs.system}.default
    ];
  };
}

