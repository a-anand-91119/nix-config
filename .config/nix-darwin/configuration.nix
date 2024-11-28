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

  environment.shells = [
    pkgs.zsh
  ];

  # pam_reattach support to get TouchId work with tmux
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    '';
  };

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

  homebrew = {
    enable = true;
    brews = [];
    taps = [
      "homebrew/homebrew-cask"
      "homebrew/homebrew-core"
    ];
    masApps = {
      Amphetamine = 937984704;
      Tailscale = 1475387142;
      LocalSend = 1661733229;
    };
    casks = [
      "the-unarchiver"
      "alacritty"
      "font-meslo-lg-nerd-font"
    ];
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
    onActivation.autoUpdate = true;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true; # default shell on catalina
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    ";
    variables = {
      BAT_THEME = "tokyonight_night";
      YSU_MESSAGE_POSITION = "after";
    };
    shellInit = ''
    '';
  };

  # Allow install of non open-source apps
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
#  services.karabiner-elements.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User accounts and home directory
  users.users.aanand = {
      name = "aanand";
      home = "/Users/aanand";
  };

  # Default system settings
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = true; # Most Recently Used spaces.
    finder.AppleShowAllExtensions = true;
    # Finder display options are: Nlsv (list), clmv (column), Flwv (cover flow), icnv (icon view)
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/Screenshots";
  };

  # Enable sudo authentication with Touch ID.
  security.pam.enableSudoTouchIdAuth = true;

  # Nix-darwin does not link installed applications to the user environment. This means apps will not show up
  # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
  # Upstream issue: https://github.com/LnL7/nix-darwin/issues/214
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';
}
