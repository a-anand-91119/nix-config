{ config, pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      # ----- Bat (better cat) -----
      theme = "tokyonight_night";
    };
    themes = {
      tokyonight_night = {
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "tokyonight.nvim";
          rev = "c2725eb6d086c8c9624456d734bd365194660017";
          sha256 = "sha256-vKXlFHzga9DihzDn+v+j3pMNDfvhYHcCT8GpPs0Uxgg=";
        };
        file = "extras/sublime/tokyonight_night.tmTheme";
      };
    };
  };
}
