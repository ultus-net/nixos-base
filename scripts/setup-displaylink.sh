#!/usr/bin/env bash
set -euo pipefail

# Simple helper to prepare the DisplayLink driver blob for NixOS.
#
# This script:
#   1. Downloads the official Ubuntu DisplayLink driver ZIP using nix-prefetch-url
#      (so Nix can legally cache it under the expected name).
#   2. Prints the resulting store path/hash, after which you can run:
#        sudo nixos-rebuild switch --flake .#work-laptop
#
# NOTE: By running this, you are implicitly accepting Synaptics/DisplayLink's
# EULA for the driver download. See their site for details.

set -x

NAME="displaylink-620.zip"
URL="https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip"

echo "Preparing DisplayLink driver blob for Nix (name: $NAME)" >&2
echo "Source: $URL" >&2

nix-prefetch-url --name "$NAME" "$URL"

echo
echo "If the above nix-prefetch-url succeeded, you can now build with DisplayLink enabled, e.g.:" >&2
echo "  sudo nixos-rebuild switch --flake .#work-laptop" >&2
