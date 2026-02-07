{ pkgs, ... }:
{
  # Declarative taps for Homebrew
  homebrew = {
    taps = [
      "homebrew/homebrew-cask"
      "homebrew/homebrew-core"
    ];
  };
}
