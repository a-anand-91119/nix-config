{ host, pkgs, ... }:
{
  # User CLI tools live in Home Manager; this is the explicitly selected
  # system helper. The personal Nix Apps activation script is not imported.
  environment.systemPackages = [ pkgs.mkalias ];

  homebrew = {
    enable = host.manageHomebrew;
    brews = [ ];
    casks = [
      "font-meslo-lg-nerd-font"
    ];
    onActivation = {
      cleanup = "none";
      upgrade = false;
      autoUpdate = false;
    };
  };
}
