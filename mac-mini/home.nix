{ config, pkgs, sharedPath, ... }:
{
  home = {
    stateVersion = "23.05";

    packages = [];

    file = {
      ".p10k.zsh".text = builtins.readFile (sharedPath + "/resources/.p10k.zsh");
      ".nanorc".text = "include ${pkgs.nano}/share/nano/*.nanorc";
    };

    sessionVariables = {};
  };

  programs = {
    home-manager.enable = true;
    zoxide.enable = true;
    fastfetch.enable = true;
    ripgrep.enable = true;
    direnv.enable = true;
  };

  imports = [
    (import (sharedPath + "/apps/cli-common.nix"))
    (import (sharedPath + "/apps/git.nix"))
    (import (sharedPath + "/apps/tmux.nix"))
  ];
}
