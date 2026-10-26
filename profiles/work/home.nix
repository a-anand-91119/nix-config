{ pkgs, ... }:
let
  # Real executables, unlike aliases, are visible to Makefiles and scripts.
  docker = pkgs.writeShellScriptBin "docker" ''exec ${pkgs.podman}/bin/podman "$@"'';
  docker-compose = pkgs.writeShellScriptBin "docker-compose" ''exec ${pkgs.podman-compose}/bin/podman-compose "$@"'';

  # Manage the Podman VM: pm up|down|rootful|rootless|status.
  pm = pkgs.writeShellApplication {
    name = "pm";
    runtimeInputs = [ pkgs.podman ];
    text = builtins.readFile ../../resources/podman/pm.sh;
  };
in
{
  # Use the built-in macOS editor without requiring another GUI application.
  home.sessionVariables = {
    EDITOR = "/usr/bin/vi";
    VISUAL = "/usr/bin/vi";
    # Socket-level Docker clients (Testcontainers, docker-py, …) reach the Podman VM here.
    # macOS's per-user TMPDIR is stable, so this needs no running machine at shell startup.
    DOCKER_HOST = "unix://\${TMPDIR%/}/podman/podman-machine-default-api.sock";
  };

  home.packages = [
    # GitLab CLI for merge requests against the self-hosted instance.
    pkgs.glab
    # GitHub CLI.
    pkgs.gh
    # AWS command-line interface (v2).
    pkgs.awscli2
    # Python package and project manager.
    pkgs.uv
    # JavaScript runtime (22.x LTS line for project tooling).
    pkgs.nodejs_22
    # Installed directly because corepack cannot write shims into the Nix store.
    pkgs.pnpm
    # Container engine; the nixpkgs build bundles vfkit/krunkit for `podman machine` on macOS.
    pkgs.podman
    # Docker Compose-compatible frontend that drives Podman.
    pkgs.podman-compose
    # Stores registry logins in the macOS Keychain.
    pkgs.docker-credential-helpers
    # Terminal UI for containers; reaches Podman through DOCKER_HOST.
    pkgs.lazydocker
    docker
    docker-compose
    pm
  ];

  programs.zsh.shellAliases = {
    cc = "claude";
    ccd = "claude --dangerously-skip-permissions";
    python = "python3";
    pip = "pip3";
    # Same as the oh-my-zsh sublime plugin used on personal.
    st = "subl";
    stt = "subl .";
  };

  # A user registries.conf replaces the system one, so restore Docker's short-name default.
  xdg.configFile."containers/registries.conf".text = ''
    unqualified-search-registries = ["docker.io"]
    credential-helpers = ["osxkeychain"]
  '';

  # `docker compose` / `podman compose`: call podman-compose directly and skip its banner.
  xdg.configFile."containers/containers.conf".text = ''
    [engine]
    compose_providers = ["${pkgs.podman-compose}/bin/podman-compose"]
    compose_warning_logs = false
    # Where Podman Desktop and `podman machine` find gvproxy, vfkit and krunkit.
    helper_binaries_dir = [
      "${pkgs.podman}/libexec/podman",
      "${pkgs.vfkit}/bin",
      "${pkgs.krunkit}/bin"
    ]
  '';

  # Install the app through Nix; the Homebrew cask is disabled by Gatekeeper policy.
  programs.alacritty.package = pkgs.alacritty;

  # Real app bundles in the managed user folder can be indexed by Spotlight.
  # Explicitly migrate from the symlink mode retained by our older stateVersion.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
