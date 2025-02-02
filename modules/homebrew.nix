{ pkgs, config, ... }:

{
  homebrew = {
      enable = true;
      brews = [
        "gsed"
        "kubectl"
        "helm"
        "k9s"
      ];
      taps = [
        "homebrew/homebrew-cask"
        "homebrew/homebrew-core"
      ];
      masApps = {
        Amphetamine = 937984704;
        Tailscale = 1475387142;
        LocalSend = 1661733229;
        WhatsApp = 310633997;
      };
      casks = [
        "the-unarchiver"
        "alacritty"
        "font-meslo-lg-nerd-font"
        "font-monaspace-nerd-font"
        "font-noto-sans-symbols-2"
        "ghostty"
      ];
      onActivation = {
        cleanup = "zap";
        upgrade = true;
        autoUpdate = true;
      };
    };
}