{ host, pkgs, ... }:
{
  imports = [ ../../modules/security.nix ];

  # User CLI tools live in Home Manager; this is the explicitly selected
  # system helper. The personal Nix Apps activation script is not imported.
  environment.systemPackages = [ pkgs.mkalias ];

  homebrew = {
    enable = host.manageHomebrew;
    brews = [
      "k6"
    ];
    casks = [
      "font-meslo-lg-nerd-font"
      "session-manager-plugin"
      "sublime-text"
    ];
    onActivation = {
      cleanup = "none";
      upgrade = false;
      autoUpdate = false;
    };
  };
}
