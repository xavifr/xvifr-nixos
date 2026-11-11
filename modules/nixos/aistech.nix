{
  config,
  lib,
  pkgs,
  ...
}:
{
  #services.unifi = {
  #  enable = true;
  #  openFirewall = true; # Automatically opens the necessary ports
  #  unifiPackage = pkgs.unifi; # Uses the stable version
  #};

  services.icecream.daemon = {
    enable = true;
    hostname = "AISCL032";
    maxProcesses = 2;
    openBroadcast = true;
    openFirewall = true;
    user = "xavier";
  };

  services.ollama = {
    enable = true;
    loadModels = ["qwen2.5-Coder:7b-base" "qwen2.5-Coder:1.5b-base"];
  };
}
