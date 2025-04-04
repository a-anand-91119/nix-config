{ pkgs, config, ... }:

{
  imports = [
    ./modules/environment.nix
    ./modules/homebrew.nix
    ./modules/nix-settings.nix
    ./modules/programs.nix
    ./modules/security.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
