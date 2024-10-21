{ config, pkgs, user, ... }:

let
  wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
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

      configFile = {
        "discoverrc"."FlatpakSources"."Sources" = "flathub";
      };
    };

    firefox = {
      enable = true;

      profiles.default = {
        search = {
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Google" ];
          force = true;
        };
      };
    };
  };

  home.stateVersion = "24.05";
}
