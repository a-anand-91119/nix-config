{ config, pkgs, ... }:
{
  # Supply-chain hardening for JS package managers.
  # Each tool gates on "release age" but with a DIFFERENT key name and time unit.
  #
  # These become read-only symlinks into the nix store. Don't put registry auth
  # tokens here (they'd land in git + the file can't be written by `npm login`);
  # use an env var or a separate unmanaged file for secrets.
  home.file = {

    # ---- npm (~/.npmrc) ----
    # min-release-age needs npm >= 11.10.0; you're on 11.6.2, so bump npm for it
    # to take effect. The other keys work on current npm.
    ".npmrc".text = ''
      # Skip versions published < 7 days ago (cooldown vs. freshly-compromised releases).
      min-release-age=7

      # Allow git-sourced deps only from your OWN package.json; block git deps
      # pulled in transitively (a supply-chain red flag). Values: all | none | root.
      # npm 12+ feature (12 defaults to `none`); inert on your current 11.6.2.
      allow-git=root

      # Block dependency pre/post-install scripts — the most common npm malware vector.
      # Tradeoff: breaks packages that need native builds (node-gyp, esbuild, ...).
      # Re-enable in a specific repo via a local .npmrc with: ignore-scripts=false
      ignore-scripts=true

      # Deterministic installs: pin exact versions and always use the lockfile.
      save-exact=true
      package-lock=true

      # Surface advisories on install; `npm audit` exits non-zero at high+.
      audit=true
      audit-level=high
    '';

    # ---- bun (~/.bunfig.toml) ----
    ".bunfig.toml".text = ''
      [install]
      # Release-age cooldown — bun uses SECONDS. 7 days = 604800.
      minimumReleaseAge = 604800
      # Pin exact versions.
      exact = true

      # bun runs dependency lifecycle scripts only for `trustedDependencies`
      # (declared in package.json) plus a small built-in allowlist, so dep
      # postinstall is already blocked by default.

      # Optional pre-install vulnerability scanner (needs the scanner pkg installed):
      # [install.security]
      # scanner = "@socketsecurity/bun-security-scanner"
    '';

    # ---- pnpm (~/.config/pnpm/config.yaml) ----
    # Global config.yaml is a pnpm v11+ location. You're on 10.22, so this kicks in
    # after your next `dr` upgrades pnpm (homebrew.onActivation.upgrade = true).
    # On v10 the setting only applies via each project's pnpm-workspace.yaml.
    ".config/pnpm/config.yaml".text = ''
      # Release-age cooldown — pnpm uses MINUTES. 7 days = 10080.
      minimumReleaseAge: 10080

      # Block transitive deps that resolve via git/tarball URLs (a common
      # supply-chain bypass for the registry). Default true in pnpm v11.
      blockExoticSubdeps: true

      # Refuse to install a version whose trust evidence (provenance, signed
      # publishes, etc.) is weaker than an earlier release of the same pkg —
      # catches the "trusted maintainer turns malicious / loses 2FA" pattern.
      # Only documented value: no-downgrade.
      trustPolicy: no-downgrade

      # pnpm v10+ already blocks dependency build scripts by default. Leave
      # dangerouslyAllowAllBuilds OFF and allowlist trusted builders explicitly:
      #   allowBuilds:
      #     esbuild: true
    '';
  };
}
