{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  home.file = {
    # Copying powerlevel10k config file to home folder
    ".p10k.zsh".text = builtins.readFile ./resources/.p10k.zsh;
    ".config/alacritty/themes/themes/coolnight.toml".text = builtins.readFile ./resources/alacritty/themes/coolnight.toml;
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/davish/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sublime"
      ];
    };
    shellAliases = {
      # better ls
      ls = "eza --color=always --git --icons=always";
      ll = "ls -l";
      lla = "ls -la";
      cat = "bat";

      # git related alias
      gaa = "git add .";
      ga = "git add";
      gc = "git commit";
      gst = "git status";
      gs = "git status";
      gd = "git diff";
      gl = "git pull";
      gpl = "git pull";
      gp = "git push";
      gpuf  = "git push --force";
      gatc = "git commit --amend --no-edit";
    };

    profileExtra = ''
     # profile extra
    '';

    initExtra = ''
      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      eval "$(fzf --zsh)"
      export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      # Use fd to generate the list for directory completion
      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

    '';

    initExtraFirst = ''
      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    initExtraBeforeCompInit = ''
      # initExtraBeforeCompInit extra
    '';


  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    sensibleOnTop = false;
    keyMode = "vi";
    mouse = true;
    customPaneNavigationAndResize = true;

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
# https://github.com/fabioluciano/tmux-tokyo-night/tree/v1.10.0?tab=readme-ov-file
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
      set -ag terminal-overrides ",xterm-256color:RGB"

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Vertical window split
      unbind %
      bind | split-window -h

      # Horizontal window split
      unbind '"'
      bind - split-window -v

      # remove delay for exiting insert mode with ESC in Neovim
      set -sg escape-time 10

      # Synchorize / Un-synchronize panes
      bind C-s setw synchronize-panes

      # start selecting text with "v"
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      # copy text with "y"
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # don't exit copy mode when dragging with mouse
      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "a.anand.91119@gmail.com";
    userName = "A Anand";
    delta.enable = true;
    delta.options = {
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-decoration-style = "none";
        file-style = "bold yellow ul";
        navigate = true;
        side-by-side = true;
      };
      features = "decorations";
      whitespace-error-style = "22 reverse";
    };
    extraConfig = {
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux";
      };

      env = {
        TERM = "xterm-256color";
      };

      window = {
        padding.x = 10;
        padding.y = 10;

        decorations = "Buttonless";
        startup_mode = "SimpleFullscreen";
        opacity = 0.7;
        blur = true;
        option_as_alt = "Both";
      };

      font = {
        normal.family = "MesloLGS Nerd Font Mono";
        size = 18;
      };

      keyboard = {
        bindings = [
          {
            key = "Right";
            mods = "Alt";
            chars = "\\u001BF";
          }
          {
            key = "Left";
            mods = "Alt";
            chars = "\\u001BB";
          }
        ];
#        bindings = [
#          { key = "Right", mods = "Alt", chars = "\u001BF", },
#          { key = "Left", mods = "Alt", chars = "\u001BB", }
#        ];
      };
      general = {
        import = [
          "~/.config/alacritty/themes/themes/coolnight.toml"
        ];
      };
    };
  };
}
