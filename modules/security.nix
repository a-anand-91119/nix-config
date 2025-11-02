{ pkgs, config, ... }:

{
  # Enable sudo authentication with Touch ID and tmux support
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # Enable reattachment for tmux/screen support (fixes TouchID in tmux)
    reattach = true;
  };
}
