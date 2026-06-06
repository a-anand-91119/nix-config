{ config, pkgs, ... }:
{
  # lockfile-lint: static analysis on package-lock.json for supply-chain hygiene.
  # Checks resolved URLs come from allowed hosts, integrity hashes are sha512,
  # resolved URL matches the package name, https-only, etc.
  #
  # Not in nixpkgs. Same Option-C wrapper pattern as sfw: delegates to the
  # upstream npm package via npx (no version pin / hash bookkeeping).
  #
  # Strict defaults are baked in — running plain `lockfile-lint` in any repo
  # enforces an "npmjs-only, https-only, integrity-required" policy. Override
  # per-invocation by appending flags (yargs: scalars last-wins, booleans take
  # `--no-X`, arrays append). For repos that legitimately consume git deps,
  # commit a `.lockfile-lintrc.json` instead of fighting the wrapper.
  #
  # Scope: npm + yarn lockfiles only. pnpm-lock.yaml is structurally safe
  # against the attacks this tool catches (per upstream FAQ) and is unsupported.
  home.packages = [
    (pkgs.writeShellScriptBin "lockfile-lint" ''
      exec npx -y lockfile-lint@latest \
        --type npm \
        --path package-lock.json \
        --allowed-hosts npm \
        --validate-https \
        --validate-integrity \
        --validate-package-names \
        --empty-hostname false \
        "$@"
    '')
  ];
}
