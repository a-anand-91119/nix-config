#!/usr/bin/env bash
set -uo pipefail

echo "=== Testing Nix configuration ==="

# Check syntax of all Nix files
echo "Checking Nix syntax..."
find . -name "*.nix" -type f -print0 | while IFS= read -r -d '' file; do
  echo "Checking $file..."
  if ! nix-instantiate --parse "$file" >/dev/null; then
    echo "Error: Syntax check failed for $file"
    exit 1
  fi
done
echo "✓ Syntax checks passed"

# Check that the flake evaluates correctly
echo "Checking flake evaluation..."
if ! nix flake check; then
  echo "Error: Flake check failed"
  exit 1
fi
echo "✓ Flake check passed"

# Dry-run build to check configuration
echo "Dry-run build of configuration..."
if ! nix build .#darwinConfigurations."Anands-MacBook-Pro--M3-Pro".system --dry-run; then
  echo "Error: Dry-run build failed"
  exit 1
fi
echo "✓ Dry-run build passed"

echo "✅ All tests passed successfully!"
exit 0 