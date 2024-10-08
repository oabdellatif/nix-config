{ pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 25;
    KeyRepeat = 2;
  };

  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    brews = [
      {
        name = "emacs-plus";
        args = [ "with-native-comp" "with-savchenkovaleriy-big-sur-icon" ];
      }
    ];
    # casks = [
    #   "firefox"
    #   "discord"
    #   "obsidian"
    #   "jagex"
    #   "runelite"
    #   "keka"
    #   "nvidia-geforce-now"
    #   "google-drive"
    #   }
    # ];
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.oabdellatif = {
    name = "oabdellatif";
    home = "/Users/oabdellatif";
  };
}