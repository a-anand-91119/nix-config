{ pkgs, config, ... }:

{
  # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = [
      pkgs.neovim
      pkgs.mkalias
      pkgs.stow
      pkgs.mas
      pkgs.tmux
      pkgs.zsh
      pkgs.bat
      pkgs.btop
      pkgs.eza
      pkgs.git
      pkgs.fzf # Fuzzy finder
      pkgs.zsh-powerlevel10k
      pkgs.meslo-lg
      pkgs.zsh-autosuggestions
      pkgs.zsh-you-should-use
      pkgs.zoxide # Directory jump tool (z)
      pkgs.delta # Terminal git diff viewer with syntax highlighting
      pkgs.pam-reattach
      pkgs.nerd-fonts.fira-code
      pkgs.lazydocker # Docker TUI
      pkgs.lazygit # Git TUI
      pkgs.curl # Command line tool for transferring data with URL syntax
      pkgs.jq # Command line JSON processor
      pkgs.yq # Command line YAML processor
      pkgs.vscode # Visual Studio Code
      pkgs.htop # Interactive process viewer
      pkgs.tree # Display directories as trees
      pkgs.jetbrains-mono # JetBrains Mono font
    ];

    # Add Zsh as a valid shell.
    environment.shells = [
        pkgs.zsh
      ];

  # Custom aliases in the shell environment
    environment.shellAliases = {
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
}