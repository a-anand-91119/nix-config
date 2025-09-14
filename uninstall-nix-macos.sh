#!/bin/bash

# Nix Uninstaller for macOS
# Based on official documentation: https://nix.dev/manual/nix/2.21/installation/uninstall

set -e

echo "🗑️  Starting Nix uninstallation for macOS..."
echo "⚠️  This will completely remove Nix from your system!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "1. Restoring shell configuration files..."
if [ -f /etc/zshrc.backup-before-nix ]; then
    echo "  Restoring /etc/zshrc"
    sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
else
    echo "  No zshrc backup found, skipping"
fi

if [ -f /etc/bashrc.backup-before-nix ]; then
    echo "  Restoring /etc/bashrc"
    sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
else
    echo "  No bashrc backup found, skipping"
fi

if [ -f /etc/bash.bashrc.backup-before-nix ]; then
    echo "  Restoring /etc/bash.bashrc"
    sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc
else
    echo "  No bash.bashrc backup found, skipping"
fi

echo "2. Stopping and removing Nix daemon services..."
if sudo launchctl list | grep -q org.nixos.nix-daemon; then
    echo "  Unloading org.nixos.nix-daemon"
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
fi

if [ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]; then
    echo "  Removing org.nixos.nix-daemon.plist"
    sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
fi

if sudo launchctl list | grep -q org.nixos.darwin-store; then
    echo "  Unloading org.nixos.darwin-store"
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
fi

if [ -f /Library/LaunchDaemons/org.nixos.darwin-store.plist ]; then
    echo "  Removing org.nixos.darwin-store.plist"
    sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist
fi

echo "3. Removing nixbld group and build users..."
if sudo dscl . -read /Groups/nixbld &>/dev/null; then
    echo "  Removing nixbld group"
    sudo dscl . -delete /Groups/nixbld
fi

echo "  Removing nixbld users"
for u in $(sudo dscl . -list /Users | grep _nixbld); do
    echo "    Removing user $u"
    sudo dscl . -delete /Users/$u
done

echo "4. Checking fstab for Nix Store mount..."
if grep -q "UUID.*nix" /etc/fstab 2>/dev/null; then
    echo "  ⚠️  Found Nix Store mount in /etc/fstab"
    echo "  Please run 'sudo vifs' and remove the line containing '/nix'"
    echo "  Press Enter when done..."
    read
else
    echo "  No Nix Store mount found in /etc/fstab"
fi

echo "5. Removing /etc/synthetic.conf entry..."
if [ -f /etc/synthetic.conf ]; then
    if grep -q "nix" /etc/synthetic.conf; then
        echo "  Removing nix entry from /etc/synthetic.conf"
        sudo sed -i '' '/nix/d' /etc/synthetic.conf
        # Remove file if it's now empty
        if [ ! -s /etc/synthetic.conf ]; then
            sudo rm /etc/synthetic.conf
        fi
    else
        echo "  No nix entry found in /etc/synthetic.conf"
    fi
else
    echo "  No /etc/synthetic.conf file found"
fi

echo "6. Removing Nix-related files and directories..."
sudo rm -rf /etc/nix
sudo rm -rf /var/root/.nix-profile
sudo rm -rf /var/root/.nix-defexpr
sudo rm -rf /var/root/.nix-channels
rm -rf ~/.nix-profile
rm -rf ~/.nix-defexpr
rm -rf ~/.nix-channels

echo "7. Removing Nix Store volume..."
if diskutil list | grep -q "Nix Store"; then
    echo "  Found Nix Store volume, removing..."
    sudo diskutil apfs deleteVolume /nix
else
    echo "  No Nix Store volume found"
fi

echo "✅ Nix uninstallation completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Restart your terminal or reload shell configuration"
echo "  2. Reboot your system to complete the cleanup"
echo "  3. The empty /nix directory will disappear after reboot"
echo ""
echo "🔍 You may want to check for any remaining Nix references in:"
echo "  - ~/.bashrc, ~/.zshrc, ~/.profile"
echo "  - Any custom shell configuration files"