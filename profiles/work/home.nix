{ pkgs, ... }:
{
  # Use the built-in macOS editor without requiring another GUI application.
  home.sessionVariables = {
    EDITOR = "/usr/bin/vi";
    VISUAL = "/usr/bin/vi";
  };

  # Install the app through Nix; the Homebrew cask is disabled by Gatekeeper policy.
  programs.alacritty.package = pkgs.alacritty;
}
