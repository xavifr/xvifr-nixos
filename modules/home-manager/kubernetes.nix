{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.modules.kubernetes;
in {
  options.modules.kubernetes = {
    enable = mkEnableOption "kubernetes tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      k9s
      helm
      minikube
    ];

    # Optional: Add kubectl configuration
    # xdg.configFile."kubectl/config".source = ./kubectl-config;
  };
} 