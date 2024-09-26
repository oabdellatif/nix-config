{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "oabdellatif";
  home.homeDirectory = "/Users/oabdellatif";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fira-code
    (nerdfonts.override {
      fonts = [ "NerdFontsSymbolsOnly" ];
    })
  ];

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    userName = "Omar Abdellatif";
    userEmail = "oahabdellatif@gmail.com";
  };

  #home.file.".emacs.d" = {
  #  source = ./emacs.d;
  #  recursive = true;
  #};
}
