{ pkgs, config, ... }:

{
  homebrew = {
      enable = true;
      brews = [
        "gsed"
      ];
      taps = [
        "homebrew/homebrew-cask"
        "homebrew/homebrew-core"
      ];
      masApps = {
        Amphetamine = 937984704;
        Tailscale = 1475387142;
        LocalSend = 1661733229;
      };
      casks = [
        "the-unarchiver"
        "alacritty"
        "font-meslo-lg-nerd-font"
        "font-monaspace-nerd-font"
        "font-noto-sans-symbols-2"
      ];
      onActivation.cleanup = "zap";
      onActivation.upgrade = true;
      onActivation.autoUpdate = true;
    };
}