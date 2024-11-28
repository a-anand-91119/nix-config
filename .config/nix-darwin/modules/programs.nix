{ pkgs, config, ... }:
{

# Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true; # default shell on catalina
    enableFzfCompletion = true;
    enableFzfGit = false;
    enableFzfHistory = false;
    enableSyntaxHighlighting = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
    ";
    # TODO: Figure out why fzf history search is not working and fix it.
#    source ${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
    variables = {
      BAT_THEME = "tokyonight_night";
      YSU_MESSAGE_POSITION = "after";
      ZSH_THEME = "robbyrussel";
    };
    shellInit = ''
    '';
  };

}