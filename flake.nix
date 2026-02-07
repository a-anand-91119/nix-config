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
    let
      # Common specialArgs for all machines
      commonSpecialArgs = {
        pkgs-stable = import nixpkgs-stable {
          config.allowUnfree = true;
        };
      };

      # Use explicit path concatenation to reference machine directories
      macbookPath = ./. + "/macbook";
      macminiPath = ./. + "/mac-mini";
      sharedPath = ./. + "/shared";

      # Helper function to build darwin configuration
      buildDarwinConfig = { path, system }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = commonSpecialArgs;

          modules = [
            (import (sharedPath + "/modules/nix-settings.nix"))
            (import (sharedPath + "/modules/security.nix"))
            (import (sharedPath + "/modules/users.nix"))
            (import (sharedPath + "/modules/programs-base.nix"))
            (import (path + "/configuration.nix"))
            {
              system.configurationRevision = self.rev or self.dirtyRev or null;
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aanand = import (path + "/home.nix");
              home-manager.extraSpecialArgs = {
                inherit sharedPath;
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = false;
                user = "aanand";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
              };
            }
          ];
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild switch --flake .#macbook
      darwinConfigurations = {
        macbook = buildDarwinConfig {
          path = macbookPath;
          system = "aarch64-darwin";
        };

        mac-mini = buildDarwinConfig {
          path = macminiPath;
          system = "aarch64-darwin";
        };
      };

      # Backward compatibility for old hostname
      darwinConfigurations."Anands-MacBook-Pro--M3-Pro" = buildDarwinConfig {
        path = macbookPath;
        system = "aarch64-darwin";
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.macbook.pkgs;
    };
}
