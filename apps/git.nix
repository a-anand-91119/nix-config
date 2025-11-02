{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "a.anand.91119@gmail.com";
        name = "A Anand";
      };
    };
    settings = {
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };
}
