{ host, lib, pkgs, ... }:
{
  # User CLI tools live in Home Manager; this is the explicitly selected
  # system helper. The personal Nix Apps activation script is not imported.
  environment.systemPackages = [ pkgs.mkalias ];

  homebrew = {
    enable = host.manageHomebrew;
    brews = [ ];
    casks = [
      "alacritty"
      "font-meslo-lg-nerd-font"
    ] ++ lib.optional (!host.vscodeManagedExternally) "visual-studio-code";
    onActivation = {
      cleanup = "none";
      upgrade = false;
      autoUpdate = false;
    };
  };
}
