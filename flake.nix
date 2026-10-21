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
    homebrew-xykong = {
      url = "github:xykong/homebrew-tap";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # herdr: terminal workspace manager for AI coding agents (built from source)
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }:
    let
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
      personal = mkHost (import ./hosts/personal-macbook.nix);
      work = mkHost (import ./hosts/work-mini.nix);
    in
    {
      darwinConfigurations = {
        "Anands-MacBook-Pro--M3-Pro" = personal;
        work-mini = work;
      };

      # Preserve the existing convenience output and personal overlay.
      darwinPackages = personal.pkgs;

      checks.aarch64-darwin = {
        personal-macbook = personal.system;
        work-mini = work.system;
        work-selection = import ./tests/work-profile.nix { inherit (work) config pkgs; };
      };
    };
}
