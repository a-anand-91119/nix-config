let
  username = "aanand";
  homeDirectory = "/Users/${username}";
in
{
  name = "Anands-MacBook-Pro--M3-Pro";
  profile = "personal";
  system = "aarch64-darwin";
  inherit username homeDirectory;
  configDirectory = "${homeDirectory}/nix-config";

  # Git identity is independent of SSH/HTTPS authentication on this Mac.
  git = {
    name = "A Anand";
    email = "a.anand.91119@gmail.com";
  };

  # Set false when the Nix daemon is managed outside nix-darwin.
  manageNix = true;
  manageHomebrew = true;
  # Opt in only when intentionally handing an existing Brew installation over.
  migrateHomebrew = false;
}
