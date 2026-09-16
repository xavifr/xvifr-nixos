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
    hostname = "as-xvi";
    maxProcesses = 2;
    openBroadcast = true;
    openFirewall = true;
    user = "xavier";
  };

}
