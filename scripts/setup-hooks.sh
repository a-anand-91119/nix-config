#!/usr/bin/env bash
set -uo pipefail

echo "Installing Git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .githooks

# Make sure the pre-commit hook is executable
chmod +x .githooks/pre-commit

# Setup git to use these hooks
git config core.hooksPath .githooks

# Verify the hook is installed correctly
if [ "$(git config core.hooksPath)" = ".githooks" ]; then
  echo "✅ Git hooks installed successfully!"
  echo "Pre-commit hook will run: $(ls -la .githooks/pre-commit)"
else
  echo "❌ Failed to configure Git hooks path"
  exit 1
fi

# Test that the pre-commit hook can be executed
if [ -x ".githooks/pre-commit" ]; then
  echo "✓ Pre-commit hook is executable"
else
  echo "❌ Pre-commit hook is not executable"
  chmod +x .githooks/pre-commit
  echo "  Fixed: Made pre-commit hook executable"
fi

echo "Hook installation complete! Hooks will run on your next commit." 