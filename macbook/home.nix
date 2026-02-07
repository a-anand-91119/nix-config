{ config, pkgs, sharedPath, ... }:
{
  home = {
    stateVersion = "23.05";

    packages = [];

    file = {
      ".p10k.zsh".text = builtins.readFile (sharedPath + "/resources/.p10k.zsh");
      ".config/alacritty/themes/themes/coolnight.toml".text = builtins.readFile (sharedPath + "/resources/alacritty/themes/coolnight.toml");
      ".nanorc".text = "include ${pkgs.nano}/share/nano/*.nanorc";
      ".config/btop/themes/tokyo-night.theme".text = builtins.readFile (sharedPath + "/resources/btop/themes/tokyo-night.theme");
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
    ./apps/alacritty.nix
    ./apps/bat.nix
    ./apps/btop.nix
    ./apps/delta.nix
    ./apps/eza.nix
    ./apps/helix.nix
    ./apps/zsh.nix
  ];
}
