# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  outputs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    outputs.nixosModules.plasma-desktop
    outputs.nixosModules.developer-tools
  ];

  # FIXME: Add the rest of your current configuration

  # TODO: Set your hostname
  networking.hostName = "gurb";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
