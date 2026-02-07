{ config, pkgs, ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
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
  };
}
