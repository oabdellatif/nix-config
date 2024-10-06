{ config, pkgs, ... }:

let
  user = "oabdellatif";
in
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

    workspace.lookAndFeel = "org.kde.breezedark.desktop";
  };
}
