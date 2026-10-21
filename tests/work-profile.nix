{ config, pkgs }:
let
  inherit (pkgs) lib;
  host = import ../hosts/work-mini.nix;
  home = config.home-manager.users.${host.username};
  packageNames = map (package: package.pname or package.name) home.home.packages;
  omittedPackages = [
    "helix"
    "fastfetch"
    "sfw"
    "lockfile-lint"
    "fnm"
    "bun"
    "uv"
    "julia"
    "rbenv"
    "rustup"
    "zsh-you-should-use"
    "fzf-git-sh"
    "lazydocker"
  ];
  omittedAliases = [
    "npm"
    "pnpm"
    "yarn"
    "npx"
    "uv"
    "cargo"
    "pip3"
    "pip"
    "python"
    "k"
    "d"
    "cc"
    "ccd"
    "cx"
    "cxd"
    "ccx"
    "ccdx"
    "oc"
    "gi"
    "gpcs"
  ];
  omittedFiles = [ ".npmrc" ".bunfig.toml" ".config/pnpm/config.yaml" ".nanorc" ];
  pluginPackages = map (plugin: plugin.plugin or plugin) home.programs.tmux.plugins;
  selectedPrograms = [
    "zsh"
    "bat"
    "btop"
    "tmux"
    "eza"
    "git"
    "fzf"
    "zoxide"
    "delta"
    "alacritty"
    "home-manager"
    "ripgrep"
    "direnv"
  ];
  selectedUtilities = with pkgs; [
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
in
assert lib.assertMsg (lib.all (name: home.programs.${name}.enable) selectedPrograms)
  "an approved work program is disabled";
assert lib.assertMsg (lib.all (package: lib.elem package home.home.packages) selectedUtilities)
  "an approved work utility is missing";
assert lib.assertMsg (home.targets.darwin.copyApps.enable && !home.targets.darwin.linkApps.enable)
  "work macOS apps must be copied for Finder and Spotlight";
assert lib.assertMsg (lib.elem pkgs.mkalias config.environment.systemPackages) "the selected mkalias helper is missing";
assert lib.assertMsg (config.homebrew.brews == [ ]) "work-mini must not inherit personal Brew formulae";
assert lib.assertMsg
  (map (cask: cask.name) config.homebrew.casks ==
  [ "font-meslo-lg-nerd-font" ])
  "work-mini casks differ from the approved selection";
assert lib.assertMsg (config.homebrew.onActivation.cleanup == "none") "work-mini must preserve unlisted Brew apps";
assert lib.assertMsg (!config.homebrew.onActivation.upgrade && !config.homebrew.onActivation.autoUpdate)
  "work-mini must not upgrade Brew during activation";
assert lib.assertMsg (lib.intersectLists omittedPackages packageNames == [ ]) "a personal package leaked into work-mini";
assert lib.assertMsg (lib.all (name: !(builtins.hasAttr name home.programs.zsh.shellAliases)) omittedAliases)
  "a personal or uninstalled-tool alias leaked into work-mini";
assert lib.assertMsg (lib.all (name: !(builtins.hasAttr name home.home.file)) omittedFiles)
  "personal package-policy dotfiles leaked into work-mini";
assert lib.assertMsg (pluginPackages == [ pkgs.tmuxPlugins.sensible ]) "work-mini must have only tmux sensible";
assert lib.assertMsg (home.programs.alacritty.package == pkgs.alacritty && lib.elem pkgs.alacritty home.home.packages)
  "Home Manager must install the work Alacritty app through Nix";
assert lib.assertMsg (!home.programs.zsh.oh-my-zsh.enable) "work-mini must not inherit personal Oh My Zsh setup";
assert lib.assertMsg (!config.security.pam.services.sudo_local.touchIdAuth && !config.security.pam.services.sudo_local.reattach)
  "work-mini must not inherit personal PAM configuration";
assert lib.assertMsg (home.programs.git.settings.user.email == host.git.email) "work Git identity does not match its host metadata";
assert lib.assertMsg (lib.hasInfix "#work-mini" home.programs.zsh.shellAliases.dr) "work rebuild shortcut targets the wrong host";
assert lib.assertMsg (!lib.hasInfix "fnm_multishells" home.programs.zsh.initContent) "work shell contains copied fnm state";
pkgs.runCommand "work-mini-selection-check" { } ''
  # Assertions above are evaluated before this derivation is available.
  touch "$out"
''
