{ pkgs, ... }:
{

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true; # default shell on catalina
    # Home Manager owns interactive completion, prompt and plugin setup.
    enableFzfCompletion = false;
    enableFzfGit = false;
    enableFzfHistory = false;
    enableSyntaxHighlighting = false;
    promptInit = "";
  };
  environment.shells = [ pkgs.zsh ];
}
