{ config, pkgs, self, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fira-code
    (nerdfonts.override {
      fonts = [ "NerdFontsSymbolsOnly" ];
    })
  ];

  programs = {
    git = {
      enable = true;

      userName = "Omar Abdellatif";
      userEmail = "oahabdellatif@gmail.com";
    };

    firefox = {
      enable = true;

      policies = {
        DisablePocket = true;
        FirefoxHome = {
          SponsoredTopSites = false;
        };
      };

      profiles.default = {
        search = {
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Google" ];
          force = true;
        };
      };
    };
  };

  home.file = {
    ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${self}/emacs.d/init.el";
    ".emacs.d/early-init.el".source = config.lib.file.mkOutOfStoreSymlink "${self}/emacs.d/early-init.el";
  };
}
