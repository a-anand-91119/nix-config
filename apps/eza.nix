{ config, pkgs, ... }:
{
  programs.eza = {
    enable = true;
    colors = "always";
    git = true;
    icons = "always";
  };
}