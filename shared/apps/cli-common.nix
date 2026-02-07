{ config, pkgs, ... }:
{
  # Common CLI tools for all machines
  home = {
    packages = with pkgs; [
      eza           # Modern ls replacement
      bat           # Modern cat replacement
      fzf           # Fuzzy finder
      fd            # Fast find replacement
      ripgrep       # Fast grep replacement
      zoxide        # smarter cd
      jq            # JSON processor
      yq            # YAML processor
      curl          # HTTP tool
      coreutils     # GNU core utilities
      gawk          # GNU awk
      delta         # Git diff viewer
    ];
  };

  # Enable these programs via Home Manager
  programs = {
    eza.enable = true;
    bat.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    zoxide.enable = true;
  };
}
