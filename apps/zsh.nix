{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.zsh";

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sublime"
      ];
    };
    shellAliases = {
      # darwin-rebuild flake
      dr = "sudo darwin-rebuild switch --flake ~/nix-config";
      # better ls
      ls = "eza";
      tree = "eza --tree";
      lla = "ls -la";
      cat = "bat";
      ccat = "bat --paging=never";
      cd = "z";
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
      gpcs = "git push -o ci.skip";
      gpuf = "git push --force";
      gatc = "git commit --amend --no-edit";
      # kubectl alias
      k = "kubectl";
      dtmux = "tmux kill-server && rm -rf /tmp/tmux-*";
      d = "docker";
    };

    initContent = ''
      # zmodload zsh/zprof

      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      ### ------------ FZF ------------- ###
      # Set up fzf key bindings and fuzzy completion
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

      # --- setup fzf theme ---
      fg="#CBE0F0"
      bg="#011628"
      bg_highlight="#143652"
      purple="#B388FF"
      blue="#06BCE4"
      cyan="#2CF9ED"

      show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

      export FZF_DEFAULT_OPTS="--color=fg:''${fg},bg:''${bg},hl:''${purple},fg+:''${fg},bg+:''${bg_highlight},hl+:''${purple},info:''${blue},prompt:''${cyan},pointer:''${cyan},marker:''${cyan},spinner:''${cyan},header:''${cyan}"
      export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
      export ZSH_DISABLE_COMPFIX=true

      # adding postgres tools
      export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
      # Support for goose
      export PATH="/Users/aanand/.local/bin:$PATH"
      # support for ruby gems
      export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

      # Advanced customization of fzf options via _fzf_comprun function
      # - The first argument to the function is the name of the command.
      # - You should make sure to pass the rest of the arguments to fzf.
      _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
          cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
          ssh)          fzf --preview 'dig {}'                   "$@" ;;
          *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
      }

      ### ------------ FZF ------------- ###

      ### ------------ jenv ------------- ###
      export PATH="$HOME/.jenv/bin:$PATH"
      # jenv add $HOMEBREW_PREFIX/opt/openjdk@23
      eval "$(jenv init - --no-rehash)"
      ### ------------ jenv ------------- ###

      ### ------------ rbenv ------------- ###
      export PATH="$HOME/.rbenv/shims:$PATH"
      echo 'eval "$(rbenv init -)"' >> ~/.zshrc
      ### ------------ rbenv ------------- ###

      # echo "--- Zsh Profiling Results ---"
      # zprof
      # echo "-----------------------------"


      # Locale Changes
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8

      # opencode
      export PATH="$HOME/.opencode/bin:$PATH"
    '';
  };
}
