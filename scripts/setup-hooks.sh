#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$repo_root"
chmod +x .githooks/pre-commit
git config --local core.hooksPath .githooks
[[ "$(git config --local core.hooksPath)" == .githooks ]]
echo "Installed the repository's pre-commit hook."
