{ config, pkgs, lib, self, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    # Bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      # Enable systemd in initrd
      systemd.enable = true;
      services.lvm.enable = true;

      verbose = false;
    };

    plymouth = {
      enable = true;

      theme = "breeze";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
      themePackages = with pkgs; [
        (kdePackages.breeze-plymouth.override {
          logoFile = config.boot.plymouth.logo;
          logoName = "nixos";
          osName = "NixOS";
          osVersion = config.system.nixos.release;
        })
      ];
    };

    # Enable silent boot
    consoleLogLevel = 3;
    kernelParams = [ "quiet" "splash" "systemd.show_status=auto" "rd.udev.log_level=3" ];
  };

  # Enable zram swap
  zramSwap.enable = true;

  # Define hostname and enable networking
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

    # Enable KDE Plasma 6
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      settings = {
        Theme = {
          CursorTheme = "breeze_cursors";
        };
      };
    };
    desktopManager.plasma6.enable = true;

    # Configure X11 keymap
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS for printing
    printing.enable = true;

    # Enable periodic TRIM
    fstrim.enable = true;

    # Enable flatpak
    flatpak.enable = true;
  };

  # Enable pipewire
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
    ];
  };

  programs = {
    # Install Firefox
    firefox.enable = true;

    # Enable Steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;

    # Overlay for signond OAuth2 plugin
    overlays = [
      (final: prev: {
        kdePackages = prev.kdePackages // {
          signon-plugin-oauth2 = final.kdePackages.callPackage ../../packages/signond/signon-plugin-oauth2.nix {};
          signond = final.kdePackages.callPackage ../../packages/signond {
            inherit (final.kdePackages) signon-plugin-oauth2;
          };

          signon-ui = final.kdePackages.callPackage ../../packages/signon-ui {};
        };
      })
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.subpixel.rgba = "rgb";
  };

  # List packages installed in system profile
  environment.systemPackages =
    let
      sddm-theme-config = pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png"
    '';
    in
    with pkgs; [
      vim
      wget
      git
      unzip
      p7zip
      kdePackages.kate
      kdePackages.kdeconnect-kde
      kdePackages.kaccounts-integration
      kdePackages.kaccounts-providers
      (kdePackages.signond.override {
        withOAuth2 = true;
        withKWallet = true;
      })
      kdePackages.signon-plugin-oauth2
      kdePackages.signon-ui
      kdePackages.kio-gdrive
      kdePackages.discover
      sddm-theme-config
      vesktop
      heroic
      mangohud
      obsidian
    ];

  system.activationScripts.copySddmDisplayConfig.text = ''
    source_file="/home/${user}/.config/kwinoutputconfig.json"
    dest_file="/var/lib/sddm/.config/kwinoutputconfig.json"

    if [ -f "$source_file" ]; then
      cp "$source_file" "$dest_file"
      chown sddm:sddm "$dest_file"
    fi
  '';

  system.stateVersion = "24.05"; # Don't change this
}
