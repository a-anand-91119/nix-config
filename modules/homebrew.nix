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
      "openjdk@11"
      "openjdk@17"
      "openjdk@21"
      "openjdk@24"
      "jenv"
      "docker-credential-helper"
      "libpq"
      "yarn"
      "watch"
      "gitlab-ci-local"
      "gradle"
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
      "corretto@8"
      "visual-studio-code"
      "bleunlock"
    ];
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
  };
}
