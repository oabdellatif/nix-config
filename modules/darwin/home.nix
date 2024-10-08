{ config, pkgs, user, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
