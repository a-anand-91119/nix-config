{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    sensibleOnTop = false;
    keyMode = "vi";
    mouse = true;
    customPaneNavigationAndResize = true;
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.logging
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-navigator

      tmuxPlugins.tmux-fzf
      {
        plugin = tmuxPlugins.fuzzback;
        extraConfig = ''
          set -g @fuzzback-hide-preview 1
        '';
      }
      #      {
      #        # https://github.com/fabioluciano/tmux-tokyo-night/tree/v1.10.0?tab=readme-ov-file
      #        plugin = tmuxPlugins.mkTmuxPlugin {
      #          pluginName = "tmux-tokyo-night";
      #          version = "v1.10.0";
      #          src = pkgs.fetchFromGitHub {
      #            owner = "fabioluciano";
      #            repo = "tmux-tokyo-night";
      #            rev = "5ce373040f893c3a0d1cb93dc1e8b2a25c94d3da";
      #            sha256 = "sha256-9nDgiJptXIP+Hn9UY+QFMgoghw4HfTJ5TZq0f9KVOFg=";
      #          };
      #        };
      #        extraConfig = ''
      #          set -g @theme_transparent_status_bar 'true'
      #        '';
      #      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10' # minutes
        '';
      }
    ];

    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:RGB"

      # Refresh tmux config with r
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Split vertically in CWD with `|`
      unbind %
      bind | split-window -h

      # Split horizontally in CWD with `-`
      unbind '"'
      bind - split-window -v

      # remove delay for exiting insert mode with ESC in Neovim
      set -sg escape-time 10

      # Synchronize / Un-synchronize panes
      bind C-s setw synchronize-panes

      # start selecting text with "v"
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      # copy text with "y"
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # don't exit copy mode when dragging with mouse
      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };
}
