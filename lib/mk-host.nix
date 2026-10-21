{ inputs }:
host:
let
  inherit (inputs.nixpkgs) lib;
  personal = host.profile == "personal";
in
assert lib.assertMsg (builtins.elem host.profile [ "personal" "work" ]) "Unknown host profile";
inputs.nix-darwin.lib.darwinSystem {
  inherit (host) system;
  specialArgs = { inherit host; };
  modules = [
    ../configuration.nix
    (if personal then ../profiles/personal/darwin.nix else ../profiles/work/darwin.nix)
    {
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      nixpkgs.overlays = lib.optional personal inputs.herdr.overlays.default;
    }
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit host; };
        users.${host.username} = import ../home.nix;
      };
    }
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ({ config, ... }: {
      nix-homebrew = {
        enable = host.manageHomebrew;
        enableRosetta = false;
        user = host.username;
        autoMigrate = host.migrateHomebrew;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        } // lib.optionalAttrs personal {
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          "xykong/homebrew-tap" = inputs.homebrew-xykong;
        };
      };
      homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
    })
  ];
}
