{ pkgs, config, ... }:

{

  system.primaryUser = "aanand";

  # Default system settings
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = true; # Most Recently Used spaces.
    finder.AppleShowAllExtensions = true;
    loginwindow.LoginwindowText = "Not Your Average Dev";
    # Finder display options are: Nlsv (list), clmv (column), Flwv (cover flow), icnv (icon view)
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/Screenshots";
  };



  # Nix-darwin does not link installed applications to the user environment. This means apps will not show up
  # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
  # Upstream issue: https://github.com/LnL7/nix-darwin/issues/214
  system.activationScripts.applications.text =
    let
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
