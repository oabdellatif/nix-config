{ config, pkgs, ... }:

{
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
