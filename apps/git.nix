{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "a.anand.91119@gmail.com";
    userName = "A Anand";
    delta.enable = true;
    delta.options = {
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-decoration-style = "none";
        file-style = "bold yellow ul";
        navigate = true;
        side-by-side = true;
      };
      features = "decorations";
      whitespace-error-style = "22 reverse";
    };
    extraConfig = {
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };
}
