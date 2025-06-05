{ pkgs, config, ... }:

{
  homebrew = {
    enable = true;
    brews = [
      "gsed"
      "kubectl"
      "helm"
      "k9s"
      "nmap"
      "operator-sdk"
      "grpcurl"
      "k6"
      "rclone"
      "pnpm"
      "openjdk@8"
      "openjdk@11"
      "openjdk@17"
      "openjdk@21"
      "openjdk@23"
      "jenv"
      "docker-credential-helper"
      "libpq"
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
      Telegram = 747648890;
    };
    casks = [
      "the-unarchiver"
      "alacritty"
      "font-meslo-lg-nerd-font"
      "font-monaspace-nerd-font"
      "font-noto-sans-symbols-2"
      "warp"
    ];
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
  };
}
