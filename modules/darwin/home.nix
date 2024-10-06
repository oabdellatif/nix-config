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
    homeDirectory = "/Users/${user}";

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
