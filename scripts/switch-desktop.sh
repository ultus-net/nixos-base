#!/usr/bin/env bash
set -euo pipefail

# Helper script to switch between desktop environments
# Usage: ./scripts/switch-desktop.sh <desktop-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Available desktops
DESKTOPS=(
  "cosmic"
  "gnome"
  "kde"
  "cinnamon"
  "xfce"
  "mate"
  "budgie"
  "pantheon"
  "lxqt"
)

show_usage() {
  echo "Usage: $0 <desktop-name>"
  echo ""
  echo "Available desktops:"
  for desktop in "${DESKTOPS[@]}"; do
    echo "  - $desktop"
  done
  echo ""
  echo "Example: $0 gnome"
  exit 1
}

if [ $# -eq 0 ]; then
  show_usage
fi

DESKTOP="$1"

# Validate desktop choice
if [[ ! " ${DESKTOPS[@]} " =~ " ${DESKTOP} " ]]; then
  echo "Error: Unknown desktop '$DESKTOP'"
  echo ""
  show_usage
fi

PROFILE_PATH="$REPO_ROOT/profiles/${DESKTOP}.nix"

if [ ! -f "$PROFILE_PATH" ]; then
  echo "Error: Profile not found at $PROFILE_PATH"
  exit 1
fi

echo "Switching to $DESKTOP desktop environment..."
echo ""
echo "This will rebuild your system with the ${DESKTOP}-workstation configuration."
echo "Current configuration will be saved as a previous generation."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Check if we're root or can sudo
if [ "$EUID" -ne 0 ]; then
  if ! command -v sudo &> /dev/null; then
    echo "Error: This script requires root privileges and sudo is not available."
    exit 1
  fi
  SUDO="sudo"
else
  SUDO=""
fi

# Rebuild the system
echo "Building configuration..."
$SUDO nixos-rebuild switch --flake "$REPO_ROOT#${DESKTOP}-workstation"

echo ""
echo "✓ Successfully switched to $DESKTOP desktop!"
echo ""
echo "You may need to:"
echo "  1. Log out and log back in"
echo "  2. Select the new desktop from your display manager"
echo "  3. Reboot if switching between Wayland/X11"
echo ""
echo "To rollback: sudo nixos-rebuild --rollback switch"
