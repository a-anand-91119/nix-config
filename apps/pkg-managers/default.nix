{ ... }:
{
  # Supply-chain hardening for language package managers.
  # Add a new module here and it's automatically picked up by home.nix.
  imports = [
    ./dotfiles.nix       # writes .npmrc / .bunfig.toml / pnpm config.yaml
    ./sfw.nix            # Socket Firewall wrapper (wraps npm/pnpm/yarn/...)
    ./lockfile-lint.nix  # static-analyzes package-lock.json
  ];
}
