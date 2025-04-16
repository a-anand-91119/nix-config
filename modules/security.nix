{ pkgs, config, ... }:

{
  # Enable sudo authentication with Touch ID.
  security.pam.services.sudo_local.touchIdAuth = true;

  # pam_reattach support to get TouchId work with tmux
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    '';
  };
}
