{ pkgs, config, ... }:
{
  imports = [
    ./system.nix
    ./environment.nix
    ./homebrew.nix
  ];
}
