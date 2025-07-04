{
  pkgs,
  ...
}:
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6 = {
    enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "es";
    variant = "cat";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.samba = {
    enable = true;
    usershares.enable = true;
    openFirewall = true;
    settings = {
      global = {
        "map to guest" = "Bad User";
        "guest account" = "nobody";
      };
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.plasma-browser-integration
    kdePackages.plasma-thunderbolt
    kdePackages.okular
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.powerdevil
    kitty

    # allow to share files between devices using dolphin
    kdePackages.kdenetwork-filesharing

    # helper to kill processes
    xorg.xkill
  ];

  programs.kdeconnect.enable = true;

  services.flatpak.enable = true;

}
