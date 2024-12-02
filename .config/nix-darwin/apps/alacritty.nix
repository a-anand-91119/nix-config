{ config, pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux";
      };

      env = {
        TERM = "xterm-256color";
      };

      window = {
        padding.x = 10;
        padding.y = 10;

        decorations = "Buttonless";
        startup_mode = "SimpleFullscreen";
        opacity = 0.7;
        blur = true;
        option_as_alt = "Both";
      };

      font = {
        normal.family = "MesloLGS Nerd Font Mono";
        size = 18;
      };

      keyboard = {
        bindings = [
          {
            key = "Right";
            mods = "Alt";
            chars = "\\u001BF";
          }
          {
            key = "Left";
            mods = "Alt";
            chars = "\\u001BB";
          }
        ];
      };
      general = {
        import = [
          "~/.config/alacritty/themes/themes/coolnight.toml"
        ];
      };
    };
  };
}