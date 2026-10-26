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
    "julia"
    "rbenv"
    "rustup"
    "zsh-you-should-use"
    "fzf-git-sh"
  ];
  omittedAliases = [
    "npm"
    "pnpm"
    "yarn"
    "npx"
    "uv"
    "cargo"
    "pip3"
    "k"
    "d"
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
assert lib.assertMsg (map (brew: brew.name) config.homebrew.brews == [ "k6" "mole" ]) "work-mini Brew formulae differ from the approved selection";
assert lib.assertMsg
  (map (cask: cask.name) config.homebrew.casks ==
  [ "font-meslo-lg-nerd-font" "session-manager-plugin" "sublime-text" ])
  "work-mini casks differ from the approved selection";
assert lib.assertMsg (config.homebrew.onActivation.cleanup == "none") "work-mini must preserve unlisted Brew apps";
assert lib.assertMsg (!config.homebrew.onActivation.upgrade && !config.homebrew.onActivation.autoUpdate)
  "work-mini must not upgrade Brew during activation";
assert lib.assertMsg (lib.intersectLists omittedPackages packageNames == [ ]) "a personal package leaked into work-mini";
assert lib.assertMsg (lib.all (name: !(builtins.hasAttr name home.programs.zsh.shellAliases)) omittedAliases)
  "a personal or uninstalled-tool alias leaked into work-mini";
assert lib.assertMsg
  (lib.all (name: builtins.hasAttr name home.programs.zsh.shellAliases) [ "cc" "ccd" "python" "pip" "st" "stt" ])
  "work-mini must define its approved Claude, Python and Sublime aliases";
assert lib.assertMsg (lib.all (name: !(builtins.hasAttr name home.home.file)) omittedFiles)
  "personal package-policy dotfiles leaked into work-mini";
assert lib.assertMsg (pluginPackages == [ pkgs.tmuxPlugins.sensible ]) "work-mini must have only tmux sensible";
assert lib.assertMsg (lib.elem pkgs.glab home.home.packages) "work-mini must install the GitLab CLI";
assert lib.assertMsg (lib.elem pkgs.uv home.home.packages) "work-mini must install uv";
assert lib.assertMsg (lib.all (name: lib.elem name packageNames) [ "ff" "ffd" ]) "work-mini must install the ff and ffd search commands";
assert lib.assertMsg (lib.elem pkgs.awscli2 home.home.packages) "work-mini must install the AWS CLI";
assert lib.assertMsg (lib.elem pkgs.nodejs_22 home.home.packages) "work-mini must install Node.js";
assert lib.assertMsg (lib.elem pkgs.pnpm home.home.packages) "work-mini must install pnpm";
assert lib.assertMsg (lib.elem pkgs.podman home.home.packages) "work-mini must install Podman";
assert lib.assertMsg (lib.elem pkgs.podman-compose home.home.packages) "work-mini must install podman-compose";
assert lib.assertMsg (lib.elem pkgs.docker-credential-helpers home.home.packages) "work-mini must install the Keychain credential helper";
assert lib.assertMsg (lib.elem pkgs.lazydocker home.home.packages) "work-mini must install lazydocker";
assert lib.assertMsg (lib.all (name: lib.elem name packageNames) [ "docker" "docker-compose" "pm" ])
  "work-mini must install the docker, docker-compose and pm commands";
assert lib.assertMsg (!(builtins.hasAttr "docker" home.programs.zsh.shellAliases))
  "docker must be a real command so Makefiles and scripts can use it";
assert lib.assertMsg (lib.hasSuffix "/podman/podman-machine-default-api.sock" home.home.sessionVariables.DOCKER_HOST)
  "work-mini DOCKER_HOST must point at the Podman machine socket";
assert lib.assertMsg (lib.hasInfix ''credential-helpers = ["osxkeychain"]'' home.xdg.configFile."containers/registries.conf".text)
  "work-mini registry logins must use the macOS Keychain";
assert lib.assertMsg (lib.hasInfix "/usr/local/bin/podman" config.system.activationScripts.postActivation.text)
  "work-mini must expose podman in /usr/local/bin for GUI apps";
assert lib.assertMsg (lib.hasInfix "helper_binaries_dir" home.xdg.configFile."containers/containers.conf".text)
  "work-mini must tell Podman where its helper binaries live";
assert lib.assertMsg (lib.hasInfix "compose_warning_logs = false" home.xdg.configFile."containers/containers.conf".text)
  "work-mini must silence the external compose provider banner";
assert lib.assertMsg (home.programs.alacritty.package == pkgs.alacritty && lib.elem pkgs.alacritty home.home.packages)
  "Home Manager must install the work Alacritty app through Nix";
assert lib.assertMsg (!home.programs.zsh.oh-my-zsh.enable) "work-mini must not inherit personal Oh My Zsh setup";
assert lib.assertMsg (config.security.pam.services.sudo_local.touchIdAuth && config.security.pam.services.sudo_local.reattach)
  "work-mini must enable sudo Touch ID with tmux PAM reattachment";
assert lib.assertMsg (home.programs.git.settings.user.email == host.git.email) "work Git identity does not match its host metadata";
assert lib.assertMsg (lib.hasInfix "#work-mini" home.programs.zsh.shellAliases.dr) "work rebuild shortcut targets the wrong host";
assert lib.assertMsg (!lib.hasInfix "fnm_multishells" home.programs.zsh.initContent) "work shell contains copied fnm state";
pkgs.runCommand "work-mini-selection-check" { } ''
  # Assertions above are evaluated before this derivation is available.
  touch "$out"
''
