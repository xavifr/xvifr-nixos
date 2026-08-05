# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  outputs,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    outputs.nixosModules.plasma-desktop
    outputs.nixosModules.developer-tools
    outputs.nixosModules.winbox
    outputs.nixosModules.aistech
    outputs.nixosModules.ninjaone-agent
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    # This is the correct parameter name for modern AMD drivers
    "amdgpu.gpu_recovery=1"
    "amdgpu.dcdebugmask=0x10"
    # Try this alternative specific to the Display Core (DC)
    "amdgpu.dc_feature_mask=0x2"
    "mem_sleep_default=deep"

    # Enable IOMMU for better security and performance
    "amd_iommu=on"

  ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  boot.initrd.luks.devices."luks-48d13175-9b4b-41cf-b7b3-0268ae7e13c8".device =
    "/dev/disk/by-uuid/48d13175-9b4b-41cf-b7b3-0268ae7e13c8";

  networking.hostName = "as-xvi";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.networkmanager.wifi.scanRandMacAddress = false;
  networking.networkmanager.settings.wifi.scan-rand-mac-address = "no";
  networking.networkmanager.settings.wifi.cloned-mac-address = "permanent";
  boot.extraModprobeConfig = ''
    options rtw89_pci disable_aspm=y
    options rtw89_core disable_ps_mode=y
  '';

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Install Bolt Daemon
  services.hardware.bolt.enable = true;

  modules.developer-tools.enable = true;

  services.ninjaone-agent = {
    enable = true;
    # Signed, org-tied installer link -- deliberately NOT fetched via Nix
    # (that would bake the identifier into the flake/store) and NOT
    # committed to git. Download it by hand with the signed link from
    # NinjaOne and place it at this exact path on as-xvi (root-owned,
    # outside the repo). Must be an absolute path outside the repo: flakes
    # only see git-tracked files for paths inside their own source tree,
    # even gitignored ones, even with --impure -- an external absolute path
    # is the only way to keep this out of git while still being readable.
    # No baseUrl/clientUIDFile needed: this installer already has the real
    # Host/ClientUID baked in by NinjaOne at download time.
    installerDeb = /home/xavier/code/xvifr-nixos/nokeep/ninjaone-agent.deb;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
