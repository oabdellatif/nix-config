{ config, lib, pkgs, user, ... }:

let
  wallpaper = "${pkgs.kdePackages.breeze}/share/wallpapers/Next/contents/images_dark/2560x1600.png";
  exceptionPattern = "(steam|vesktop|obsidian|heroic)";
in
{
  imports = [
    ../shared/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
  };

  programs = {
    home-manager.enable = true;

    plasma = {
      enable = true;

      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        wallpaper = "${wallpaper}";
      };

      panels = [
        # Default panel with pinned apps
        {
          location = "bottom";
          floating = true;
          widgets = [
            {
              kickoff = {
                icon = "nix-snowflake-white";
              };
            }
            "org.kde.plasma.pager"
            {
              iconTasks = {
                launchers = [
                  "applications:systemsettings.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:emacs.desktop"
                ];
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];

      kscreenlocker.appearance.wallpaper = "${wallpaper}";

      kwin.nightLight = {
        mode = "location";
        location = {
          latitude = "34.85";
          longitude = "-82.39";
        };
      };

      window-rules = [
        {
          description = "Force shadows on CSD windows";
          match.window-class = {
            type = "regex";
            match-whole = false;
            value = exceptionPattern;
          };

          apply."noborder" = {
            apply = "force";
            value = false;
          };
        }
      ];

      configFile = {
        "discoverrc"."FlatpakSources"."Sources" = "flathub";

        "breezerc" = {
          "Common"."OutlineIntensity" = "OutlineOff";
          "Windeco Exception 0" = {
            "BorderSize" = 0;
            "Enabled" = true;
            "ExceptionPattern" = exceptionPattern;
            "ExceptionType" = 0;
            "HideTitleBar" = true;
            "Mask" = 16;
          };
        };

        "kwinrc" = {
          "PrimaryOutline" = {
            "ActiveOutlinePalette" = 2;
            "ActiveOutlineUseCustom" = false;
            "ActiveOutlineUsePalette" = true;
            "InactiveOutlinePalette" = 2;
            "InactiveOutlineThickness" = 1.25;
            "InactiveOutlineUseCustom" = false;
            "InactiveOutlineUsePalette" = true;
            "OutlineThickness" = 1.25;
          };
          "SecondOutline" = {
            "InactiveSecondOutlineThickness" = 0;
            "SecondOutlineThickness" = 0;
          };
          "Shadow" = {
            "ActiveShadowAlpha" = 104;
            "InactiveShadowAlpha" = 80;
          };
          # FIXME: Remove the symbol later
          "ًRound-Corners" = {
            "InactiveCornerRadius" = 8;
            "InactiveShadowSize" = 40;
            "ShadowSize" = 50;
            "Size" = 8;
          };
        };
      };
    };

    firefox = {
      profiles.default = {
        settings = {
          "font.name.serif.x-western" = "Liberation Serif";
          "font.name.sans-serif.x-western" = "Liberation Sans";
        };
      };
    };
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = let
      defaultBrowser = "firefox.desktop";
    in
    {
      "x-scheme-handler/http" = "${defaultBrowser}";
      "x-scheme-handler/https" = "${defaultBrowser}";
      "x-scheme-handler/chrome" = "${defaultBrowser}";
      "text/html" = "${defaultBrowser}";
    };
  };

  systemd.user.services.drive-mount = {
    Unit = {
      Description = "Mount remote Google Drive with rclone";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Google\\x20Drive";
      ExecStart = "${pkgs.rclone}/bin/rclone mount oahabdellatif@gmail.com: %h/Google\\x20Drive --vfs-cache-mode=full --vfs-cache-max-age 30d";
      ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/Google\\x20Drive";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  home.file = {
    "${config.xdg.configHome}/autostart/steam.desktop".text = ''
      [Desktop Entry]
      Name=Steam
      Comment=Application for managing and playing games on Steam
      Exec=steam %U -silent
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;Game;
      MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
      Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;
      PrefersNonDefaultGPU=true
      X-KDE-RunOnDiscreteGpu=true
    '';

    "${config.xdg.configHome}/autostart/vesktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Vesktop
      Comment=Vesktop autostart script
      Exec="/nix/store/2ayryq3clabcblbj2ipbvcrp31h9lknx-electron-33.0.0/bin/electron" "/nix/store/z6c1gpzclnfsmb1k44my7qd5g2w8lc5y-vesktop-1.5.3/opt/Vesktop/resources/app.asar" "--enable-speech-dispatcher" "--ozone-platform-hint=auto" "--enable-features=WaylandWindowDecorations" "--enable-wayland-ime" "--start-minimized"
      StartupNotify=false
      Terminal=false
    '';

    "${config.xdg.configHome}/autostart/heroic.desktop".text = ''
      [Desktop Entry]
      Name=Heroic Games Launcher
      Exec=heroic %u
      Terminal=false
      Type=Application
      Icon=com.heroicgameslauncher.hgl
      StartupWMClass=Heroic
      Comment=An Open Source GOG and Epic Games launcher
      Comment[de]=Ein Open Source Spielelauncher for GOG und Epic Games
      MimeType=x-scheme-handler/heroic;
      Categories=Game;
    '';
  };

  home.stateVersion = "24.05";
}
