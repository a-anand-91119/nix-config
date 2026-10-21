{ pkgs, ... }:
{
  # Use the built-in macOS editor without requiring another GUI application.
  home.sessionVariables = {
    EDITOR = "/usr/bin/vi";
    VISUAL = "/usr/bin/vi";
  };

  home.packages = [
    # GitLab CLI for merge requests against the self-hosted instance.
    pkgs.glab
    # Python package and project manager.
    pkgs.uv
    # JavaScript runtime (22.x LTS line for project tooling).
    pkgs.nodejs_22
  ];

  # Install the app through Nix; the Homebrew cask is disabled by Gatekeeper policy.
  programs.alacritty.package = pkgs.alacritty;

  # Real app bundles in the managed user folder can be indexed by Spotlight.
  # Explicitly migrate from the symlink mode retained by our older stateVersion.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
