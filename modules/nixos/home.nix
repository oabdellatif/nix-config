{ config, pkgs, self, user, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
    };

    panels = [
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
                "applications:org.kde.plasma.settings.open.desktop"
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

  programs.alacritty = {
    enable = true;

    settings = {
      import = [
        "${pkgs.alacritty-theme}/breeze.toml"
      ];

      font = {
        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        size = 10.0;
      };
    };
  };
}
