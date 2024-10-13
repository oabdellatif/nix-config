{ config, pkgs, self, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    # Use systemd-boot as the bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      verbose = false;
      # Replace stage 1 with systemd
      #systemd.enable = true;
    };

    # Enable silent boot
    consoleLogLevel = 3;
    kernelParams = [ "quiet" "udev.log_level=3" ];
  };

  # Define hostname and enable NetworkManager
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Set the time zone
  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    # Enable X server
    xserver.enable = true;

    # Enable KDE Plasma 6 and SDDM
    displayManager.sddm = {
      enable = true;

      settings = {
        Theme = {
          CursorTheme = "breeze_cursors";
        };
      };
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;

    # Configure X11 keymap
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS for printing
    printing.enable = true;
  };

  # Enable PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account
  users.users.${user} = {
    isNormalUser = true;
    description = "Omar Abdellatif";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      emacs-gtk
      alacritty
      alacritty-theme
      kitty
    ];
  };

  # Install Firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    kdePackages.kate
  ];

  system.stateVersion = "24.05";
}
