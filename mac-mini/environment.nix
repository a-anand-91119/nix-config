{ pkgs, config, ... }:
{
  environment = {
    # Minimal system packages for headless dev server
    systemPackages = with pkgs; [
      zsh
      git
      bc
      coreutils
      gawk
      htop
      curl
      docker
      docker-compose
      lazydocker
      lazygit
    ];

    shells = [
      pkgs.zsh
    ];

    shellAliases = {};
  };
}
