{
  description = "Anand's MacOS Nix System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-stable, home-manager, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Anands-MacBook-Pro--M3-Pro
    darwinConfigurations."Anands-MacBook-Pro--M3-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      # The `specialArgs` parameter passes the non-default nixpkgs instances to other nix modules
      specialArgs = {
        # To use packages from nixpkgs-stable, we configure some parameters for it first
        pkgs-stable = import nixpkgs-stable {
          # Add / duplicate the system settings if stable channel cannot be used.
          # inherit system;
          # To use Chrome, we need to allow the installation of non-free software.
          config.allowUnfree = true;
        };
      };

      modules = [
        ./configuration.nix
        {
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.aanand = import ./home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;
            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;
            # User owning the Homebrew prefix
            user = "aanand";
            # Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            # Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Anands-MacBook-Pro--M3-Pro".pkgs;

  };
}
