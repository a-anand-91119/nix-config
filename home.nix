{ config, pkgs, ... }:

{
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
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
    file = {
      # Copying powerlevel10k config file to home folder
      ".p10k.zsh".text = builtins.readFile ./resources/.p10k.zsh;
      # Alacritty Theme
      ".config/alacritty/themes/themes/coolnight.toml".text = builtins.readFile ./resources/alacritty/themes/coolnight.toml;
      # Syntax highlighting in nano
      ".nanorc".text = "include ${pkgs.nano}/share/nano/*.nanorc";
      # Theme for Btop
      ".config/btop/themes/tokyo-night.theme".text = builtins.readFile ./resources/btop/themes/tokyo-night.theme;

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
    sessionVariables = {
      # EDITOR = "emacs";
    };
  };


  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    thefuck.enable = true;
    thefuck.enableInstantMode = true;
    zoxide.enable = true;
    fastfetch.enable = true;
    ripgrep.enable = true;
    direnv.enable = true;
  };

  imports = [
    ./apps/alacritty.nix
    ./apps/bat.nix
    ./apps/btop.nix
    ./apps/eza.nix
    ./apps/git.nix
    ./apps/helix.nix
    ./apps/zsh.nix
    ./apps/tmux.nix
  ];
}
