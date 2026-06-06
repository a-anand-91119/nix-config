{ config, pkgs, ... }:
{
  # Socket Firewall (sfw) — wraps package managers, blocks known-malicious
  # deps before they hit disk. Not in nixpkgs, so we install via npx-on-demand:
  # this writeShellScriptBin puts an `sfw` shim on PATH that delegates to the
  # upstream npm package (which itself downloads the prebuilt binary).
  #
  # Tradeoffs of this install path vs. a pinned-binary derivation:
  #   + zero version/hash bookkeeping; tracks sfw v2 line automatically
  #   + no nixpkgs PR or fetchurl hash to maintain on upgrade
  #   - first call after a cache wipe takes a few seconds to bootstrap
  #   - bootstrap itself runs through unwrapped npm/npx (one-time hole)
  #   - requires `npx` on PATH at runtime (provided by node from brew/asdf)
  #
  # SFW_SKIP_UPDATE_CHECK=1 disables sfw's own daily background self-update
  # once a cached binary exists; remove the export to let it self-update.
  home.packages = [
    (pkgs.writeShellScriptBin "sfw" ''
      export SFW_SKIP_UPDATE_CHECK=1
      exec npx -y sfw@2 "$@"
    '')
  ];
}
