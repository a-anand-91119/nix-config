{ pkgs, config, ... }:
{
  # Allow install of non open-source apps
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  #  services.karabiner-elements.enable = true;
  # nix.package = pkgs.nix;

  nix = {
# Necessary for using flakes on this system.
  # enable flakes globally
  settings.experimental-features = [ "nix-command" "flakes" ];

  # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Optimize storage
    optimise.automatic = true;
  };


  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";


}
