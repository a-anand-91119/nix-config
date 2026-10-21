{ pkgs, ... }:
{
  # Use the built-in macOS editor without requiring another GUI application.
  home.sessionVariables = {
    EDITOR = "/usr/bin/vi";
    VISUAL = "/usr/bin/vi";
  };

  # GitLab CLI for merge requests against the self-hosted instance.
  home.packages = [ pkgs.glab ];

  # Install the app through Nix; the Homebrew cask is disabled by Gatekeeper policy.
  programs.alacritty.package = pkgs.alacritty;

  # Real app bundles in the managed user folder can be indexed by Spotlight.
  # Explicitly migrate from the symlink mode retained by our older stateVersion.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
