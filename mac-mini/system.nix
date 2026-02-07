{ pkgs, config, ... }:
{
  system = {
    primaryUser = "aanand";

    defaults = {
      loginwindow.LoginwindowText = "Anand's Headless Mac Mini";
    };

    # Headless server settings
    activationScripts.applications.text = "";
  };

  # Enable SSH server
  services.openssh.enable = true;
}
