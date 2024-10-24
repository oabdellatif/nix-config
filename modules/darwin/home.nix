{ config, pkgs, user, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";
  };

  programs = {
    home-manager.enable = true;

    firefox.package = pkgs.emptyDirectory;
  };

  home.stateVersion = "24.05";
}
