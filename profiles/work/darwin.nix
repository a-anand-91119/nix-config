{ host, pkgs, ... }:
{
  imports = [ ../../modules/security.nix ];

  # User CLI tools live in Home Manager; this is the explicitly selected
  # system helper. The personal Nix Apps activation script is not imported.
  environment.systemPackages = [ pkgs.mkalias ];

  # GUI apps (Podman Desktop) do not inherit the shell PATH and only look in standard
  # folders, so expose the Nix-managed podman there. Never replace a real file.
  system.activationScripts.postActivation.text = ''
    podman_link=/usr/local/bin/podman
    if [ ! -e "$podman_link" ] || [ -L "$podman_link" ]; then
      mkdir -p /usr/local/bin
      ln -sfn /etc/profiles/per-user/${host.username}/bin/podman "$podman_link"
    else
      echo "Leaving existing $podman_link in place; it is not a symlink." >&2
    fi
  '';

  homebrew = {
    enable = host.manageHomebrew;
    brews = [
      "k6"
      "mole"
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
