{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.agenix;
in
{
  options.modules.agenix = {
    enable = mkEnableOption "Agenix (home)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (pkgs.callPackage "${builtins.fetchTarball {
          url = "https://github.com/ryantm/agenix/archive/main.tar.gz";
          sha256 = "0ngkhf7qamibhbl9z1dryzscd36y4fz1m1h6fb2z6fylw0b8029p";
        }}/pkgs/agenix.nix" { })
    ];
  };
}
