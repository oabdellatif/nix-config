{
  description = "Omar's Darwin/NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    stylix.url = "github:danth/stylix";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, plasma-manager, stylix, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-emacs-plus }:
    let
      user = "oabdellatif";
    in {
      darwinConfigurations."Ksenias-Laptop" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/darwin/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "${user}";

              taps = {
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
              };

              mutableTaps = false;
            };
          }
	        home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/darwin/home.nix;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."Ksenias-Laptop".pkgs;

      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              users.${user} = import ./modules/nixos/home.nix;

              extraSpecialArgs = { inherit user; };
            };
          }
          stylix.nixosModules.stylix
        ];
      };
    };
}
