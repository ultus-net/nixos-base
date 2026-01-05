#!/usr/bin/env bash
set -euo pipefail

# Helper to build or switch to a named host from a flake.
# Usage:
#   ./scripts/switch-host.sh <flake-ref>
# Examples:
#   ./scripts/switch-host.sh .#cosmic-dev
#   ./scripts/switch-host.sh ./flakes/gnome#gnome-workstation

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <flake-ref>  (e.g. .#cosmic-dev or ./flakes/gnome#gnome-workstation)"
  exit 2
fi

REF="$1"

if [ "$(id -u)" -eq 0 ]; then
  echo "Running as root — switching system to $REF"
  nixos-rebuild switch --flake "$REF"
else
  echo "Not running as root — building the toplevel for $REF"
  nix build "$REF" || {
    echo "Build failed"
    exit 1
  }
  echo "Build complete. To switch as root, run: sudo nixos-rebuild switch --flake '$REF'"
fi
