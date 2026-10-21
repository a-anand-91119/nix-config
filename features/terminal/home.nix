{ config, host, lib, pkgs, ... }:
{
  # Programs managed by their Home Manager modules are not repeated here.
  home.packages = with pkgs; [
    coreutils
    gawk
    curl
    jq
    yq
    fd
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-fzf-tab
    nixpkgs-fmt
  ];
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  programs.fzf = {
    enable = true;
    # Initialized below once, together with our completion customizations.
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.zsh";
    shellAliases = {
      dr = "sudo darwin-rebuild switch --flake ${lib.escapeShellArg "${host.configDirectory}#${host.name}"}";
      ls = "eza";
      tree = "eza --tree";
      lla = "ls -la";
      cat = "bat";
      ccat = "bat --paging=never";
      cd = "z";
      gaa = "git add .";
      ga = "git add";
      gc = "git commit";
      gst = "git status";
      gs = "git status";
      gd = "git diff";
      gl = "git pull";
      gpl = "git pull";
      gp = "git push";
      gpuf = "git push --force-with-lease";
      gatc = "git commit --amend --no-edit";
      dtmux = "tmux kill-server";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkOrder 1000 ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        eval "$(fzf --zsh)"
        export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

        _fzf_compgen_path() {
          fd --hidden --exclude .git . "$1"
        }
        _fzf_compgen_dir() {
          fd --type=d --hidden --exclude .git . "$1"
        }

        show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
        export FZF_DEFAULT_OPTS="--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"
        export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

        _fzf_comprun() {
          local command=$1
          shift
          case "$command" in
            cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
            export|unset) fzf --preview "eval 'echo $'{}" "$@" ;;
            ssh) fzf --preview 'dig {}' "$@" ;;
            *) fzf --preview "$show_file_or_dir_preview" "$@" ;;
          esac
        }
      '')
    ];
  };
}
