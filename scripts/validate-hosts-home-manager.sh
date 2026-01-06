#!/usr/bin/env bash
set -euo pipefail

# Validate that each host file under `hosts/` imports the Home Manager module
# at `../modules/home-manager.nix` (or a path containing "home-manager.nix").

fail=0
for f in hosts/*.nix; do
  if grep -Eq "home-manager\.nix" "$f"; then
    echo "OK: $f imports home-manager"
    continue
  fi

  # Check for local imports (e.g. './cosmic-workstation.nix') and see if
  # any of those transitively import home-manager.
  localImports=$(grep -oE '\./[^ ]+\.nix' "$f" || true)
  found=0
  for imp in $localImports; do
    # normalize path relative to repo root
    impPath=$(realpath -m "$(dirname "$f")/$imp")
    if [ -f "$impPath" ] && grep -Eq "home-manager\.nix" "$impPath"; then
      echo "OK: $f imports $imp which imports home-manager"
      found=1
      break
    fi
  done

  if [ "$found" -eq 0 ]; then
    echo "MISSING: $f does not import home-manager (directly or via local imports)" >&2
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "One or more host files are missing Home Manager import." >&2
  exit 2
fi

echo "All host files import Home Manager." 
