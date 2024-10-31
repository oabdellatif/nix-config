{ config, lib, pkgs, user, ... }:

let
  wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images_dark/2560x1600.png";
  windowExceptions = [
    "steam"
    "vesktop"
    "obsidian"
  ];
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

      window-rules = let
      in map (app: {
        description = "Settings for ${app}";
        match.window-class = {
          match-whole = false;
          value = app;
        };
        apply."noborder" = {
          apply = "force";
          value = false;
        };
      }) windowExceptions;

      configFile = let
        windowExceptionAttrs = builtins.listToAttrs (
          builtins.genList (i: {
            name = "Windeco Exception ${toString i}";
            value = {
              "BorderSize" = 0;
              "Enabled" = true;
              "ExceptionPattern" = builtins.elemAt windowExceptions i;
              "ExceptionType" = 0;
              "HideTitleBar" = true;
              "Mask" = 16;
            };
          }) (builtins.length windowExceptions)
        );
      in
      {
        "discoverrc"."FlatpakSources"."Sources" = "flathub";

        "breezerc" = windowExceptionAttrs // {
          "Common"."OutlineIntensity" = "OutlineOff";
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

  home.stateVersion = "24.05";
}
