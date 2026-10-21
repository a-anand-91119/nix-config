{ pkgs, ... }:
{
  imports = [
    ../../apps/helix.nix
    ../../apps/pkg-managers
    ../../apps/zsh.nix
  ];
  programs.fastfetch.enable = true;
  home.packages = [ pkgs.zsh-syntax-highlighting ];
  home.file.".nanorc".text = "include ${pkgs.nano}/share/nano/*.nanorc";

  # Keep personal session persistence and all eight original plugins.
  programs.tmux.plugins = with pkgs.tmuxPlugins; [
    logging
    better-mouse-mode
    vim-tmux-navigator
    tmux-fzf
    {
      plugin = fuzzback;
      extraConfig = "set -g @fuzzback-hide-preview 1";
    }
    {
      plugin = resurrect;
      extraConfig = ''
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
      '';
    }
    {
      plugin = continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
        set -g @continuum-save-interval '10'
      '';
    }
  ];
}
