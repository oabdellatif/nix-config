{ config, pkgs, self, ... }:

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

  home.file = {
    ".emacs.d/init.el" = {
      source = config.lib.file.mkOutOfStoreSymlink "${self}/emacs.d/init.el";
    };
    ".emacs.d/early-init.el" = {
      source = config.lib.file.mkOutOfStoreSymlink "${self}/emacs.d/early-init.el";
    };
  };
}
