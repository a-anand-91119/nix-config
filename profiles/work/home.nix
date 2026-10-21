{
  # The selected VS Code cask supplies this CLI. Wait for editing to finish
  # when Git or another terminal command invokes the editor.
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };

  # Brew owns the GUI application; Home Manager only writes its settings.
  programs.alacritty = {
    package = null;
    settings.font.normal.family = "MesloLGS Nerd Font Mono";
  };
}
