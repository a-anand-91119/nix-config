{ config, host, ... }:
{
  imports = [
    ./features/terminal/home.nix
    ./apps/alacritty.nix
    ./apps/bat.nix
    ./apps/btop.nix
    ./apps/delta.nix
    ./apps/eza.nix
    ./apps/git.nix
    ./apps/tmux.nix
    (if host.profile == "personal" then ./profiles/personal/home.nix else ./profiles/work/home.nix)
  ];

  home = {
    inherit (host) username homeDirectory;
    # Compatibility baseline: do not bump merely when updating inputs.
    stateVersion = "23.05";
    file = {
      ".p10k.zsh".source = ./resources/.p10k.zsh;
      ".config/alacritty/themes/themes/coolnight.toml".source = ./resources/alacritty/themes/coolnight.toml;
      ".config/btop/themes/tokyo-night.theme".source = ./resources/btop/themes/tokyo-night.theme;
    };
    sessionVariables.XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
  };

  programs = {
    home-manager.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    direnv.enable = true;
  };
}
