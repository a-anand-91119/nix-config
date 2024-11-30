{ pkgs, config, ... }:

{
  # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      mkalias
      stow
      mas
      zsh
      bat
      btop
      tmux
      eza
      bc
      coreutils
      gawk
      git
      nowplaying-cli
      fzf # Fuzzy finder
      fd # Better find
      zsh-powerlevel10k
      meslo-lg
      zsh-autosuggestions
      zsh-you-should-use
      zoxide # Directory jump tool (z)
      delta # Terminal git diff viewer with syntax highlighting
      pam-reattach
      nerd-fonts.fira-code
      lazydocker # Docker TUI
      lazygit # Git TUI
      curl # Command line tool for transferring data with URL syntax
      jq # Command line JSON processor
      yq # Command line YAML processor
      vscode # Visual Studio Code
      htop # Interactive process viewer
      tree # Display directories as trees
      jetbrains-mono # JetBrains Mono font
      zsh-fzf-tab # Replace zsh's default completion selection menu with fzf!
      fzf-git-sh # Bash and zsh key bindings for Git objects, powered by fzf
#      zsh-fzf-history-search # Replaces Ctrl+R with an fzf-driven select
      asciinema # Terminal session recorder
    ];

    # Add Zsh as a valid shell.
    environment.shells = [
      pkgs.zsh
    ];

  # Custom aliases in the shell environment
    environment.shellAliases = {
    };
}