{ pkgs, config, ... }:
{
  homebrew = {
    enable = true;
    brews = [
      "kubectl"
      "helm"
      "k9s"
    ];

    taps = [];
    casks = [];

    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
  };
}
