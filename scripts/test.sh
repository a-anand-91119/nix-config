#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$repo_root"
# Include new modules without staging or modifying the caller's Git index.
flake="path:$repo_root"
mode=eval
hosts=()

for argument in "$@"; do
  case "$argument" in
    --syntax-only) mode=syntax ;;
    --eval-only) mode=eval ;;
    --dry-run) mode=dry-run ;;
    --build) mode=build ;;
    --*) echo "Unknown option: $argument" >&2; exit 2 ;;
    *) hosts+=("$argument") ;;
  esac
done

echo "Checking Nix syntax..."
if ! git ls-files --cached --others --exclude-standard -z -- '*.nix' |
  while IFS= read -r -d '' file; do
    # A tracked file may have been deleted in the working tree.
    [[ -f "$file" ]] || continue
    if ! nix-instantiate --parse "$file" >/dev/null; then
      echo "Syntax check failed: $file" >&2
      exit 1
    fi
  done
then
  exit 1
fi
echo "Syntax checks passed."
[[ "$mode" != syntax ]] || exit 0

echo "Evaluating flake checks and both host configurations..."
nix flake check --all-systems --no-build --no-update-lock-file "$flake"
if [[ ${#hosts[@]} -eq 0 ]]; then
  host_names=$(nix eval --raw --no-update-lock-file "$flake#darwinConfigurations" \
    --apply 'hosts: builtins.concatStringsSep "\n" (builtins.attrNames hosts)')
  while IFS= read -r host; do
    hosts+=("$host")
  done <<< "$host_names"
fi

for host in "${hosts[@]}"; do
  target="$flake#darwinConfigurations.$host.system"
  echo "Checking $host..."
  nix eval --raw --no-update-lock-file "$target.drvPath" >/dev/null
  case "$mode" in
    dry-run) nix build --no-link --no-update-lock-file --dry-run "$target" ;;
    build) nix build --no-link --no-update-lock-file "$target" ;;
  esac
done

if [[ "$mode" == build ]]; then
  nix build --no-link --no-update-lock-file "$flake#checks.aarch64-darwin.work-selection"
  echo "All requested systems built; no configuration was activated."
else
  echo "Evaluation passed. No systems were built or activated (use --build on a Mac)."
fi
