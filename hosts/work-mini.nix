let
  username = "aanand";
  homeDirectory = "/Users/${username}";
in
{
  name = "work-mini";
  profile = "work";
  system = "aarch64-darwin";
  inherit username homeDirectory;
  configDirectory = "${homeDirectory}/nix-config";

  # The existing GitHub identity, as requested. Authentication is set up separately.
  git = {
    name = "A Anand";
    email = "a.anand.91119@gmail.com";
  };

  # Use upstream Nix with nix-darwin management by default. Set manageNix to
  # false before bootstrapping with Determinate Nix or another managed daemon.
  manageNix = true;
  manageHomebrew = true;
  # Opt in only when intentionally handing an existing Brew installation over.
  migrateHomebrew = false;
  vscodeManagedExternally = false;
}
