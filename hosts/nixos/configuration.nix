{ config, pkgs, lib, self, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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

    # Use latest Zen kernel
    kernelPackages = pkgs.linuxPackages_zen;

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
    hostName = "omar-desktop";
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

    # Enable OpenRGB
    hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };
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
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    packages = with pkgs; [
      emacs29-pgtk
    ];
  };

  programs = {
    # Install Firefox
    firefox.enable = true;

    # Install Steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    # Enable GameMode
    gamemode = {
      enable = true;
      settings = {
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1;
          amd_performance_level = "high";
        };
      };
    };
  };

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;

    overlays = [
      # Missing packages for KIO GDrive
      (final: prev: {
        kdePackages = prev.kdePackages // {
          signon-plugin-oauth2 = final.kdePackages.callPackage ../../packages/signon-plugin-oauth2 {};
          signond = final.kdePackages.callPackage ../../packages/signond {
            inherit (final.kdePackages) signon-plugin-oauth2;
          };
          signon-ui = final.kdePackages.callPackage ../../packages/signon-ui {};
        };
      })
      # Force noborder on Wayland
      (final: prev: {
        kdePackages = prev.kdePackages // {
          kwin = prev.kdePackages.kwin.overrideAttrs (attrs: {
            patches = attrs.patches ++ [ ../../packages/kwin/force-noborder-wayland.patch ];
          });
        };
      })
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.subpixel.rgba = "rgb";
  };

  environment = {
    # Enable Ozone Wayland support
    sessionVariables.NIXOS_OZONE_WL = "1";

    # List packages installed in system profile
    systemPackages = let
      sddm-theme-config = pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = "${pkgs.kdePackages.breeze}/share/wallpapers/Next/contents/images_dark/2560x1600.png"
      '';
    in with pkgs; [
      vim
      wget
      git
      unzip
      p7zip
      rclone
      kdePackages.kaccounts-integration
      kdePackages.kaccounts-providers
      (kdePackages.signond.override {
        withOAuth2 = true;
        withKWallet = true;
      })
      kdePackages.signon-plugin-oauth2
      kdePackages.signon-ui
      kdePackages.kio-gdrive
      kdePackages.kate
      kdePackages.kdeconnect-kde
      kdePackages.discover
      sddm-theme-config
      kde-rounded-corners
      haruna
      vesktop
      heroic
      obsidian
      mangohud
    ];
  };

  system.activationScripts.sddmCopyDisplayConfig.text = ''
    source_file="/home/${user}/.config/kwinoutputconfig.json"
    dest_file="/var/lib/sddm/.config/kwinoutputconfig.json"

    if [ -f "$source_file" ]; then
      cp "$source_file" "$dest_file"
      chown sddm:sddm "$dest_file"
    fi
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05"; # Don't change this
}
