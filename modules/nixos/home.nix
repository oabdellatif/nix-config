{ config, pkgs, user, ... }:

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
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
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
    };

    firefox = {
      enable = true;

      profiles.default = {
        search = {
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Google" ];
          force = true;
        };

        settings = {
          "font.name.sans-serif.x-western" = "Liberation Sans";
          "font.name.serif.x-western" = "Liberation Serif";
        };
      };
    };
  };

  home.file = {
    "${config.xdg.configHome}/gtkrc".text = ''
      include "/run/current-system/sw/share/themes/Breeze/gtk-2.0/gtkrc"

      gtk-theme-name="Breeze"
    '';

    "${config.xdg.configHome}/discoverrc".text = ''
      [FlatpakSources]
      Sources=flathub
    '';
  };

  home.stateVersion = "24.05";
}
