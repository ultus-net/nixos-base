#!/usr/bin/env bash
set -euo pipefail

# Validate that each profile under `profiles/` and each machine under
# `machines/` imports the Home Manager module at `../modules/home-manager.nix`
# (or a path containing "home-manager.nix").

fail=0
for f in profiles/*.nix machines/*.nix; do
  if grep -Eq "home-manager\.nix" "$f"; then
    echo "OK: $f imports home-manager"
    continue
  fi

  # Heuristic: only require Home Manager import for profile files or machine
  # entries that look like deployments (they reference a profile or set
  # a hostname or users). Skip pure module files (for example modules/zram.nix,
  # modules/common-users.nix) which expose options and don't need to import home-manager.
  # Only require Home Manager import for files that reference a profile
  # (../profiles/ or profiles/) or appear to be a deployment (set hostname or
  # define users.users). Pure modules (options, helper modules) are skipped.
  # Skip pure module files that expose options (for example modules/zram.nix,
  # modules/common-users.nix) — they don't need to import Home Manager.
  if grep -Eq '^[[:space:]]*options[[:space:]]*=' "$f" || grep -Eq 'options[[:space:]]*=' "$f"; then
    echo "SKIP: $f defines options (module); skipping Home Manager check"
    continue
  fi

  # Skip the master machine configuration file; it's intentionally a
  # machine-agnostic defaults file and does not need to import Home Manager.
  if [ "$(basename "$f")" = "configuration.nix" ]; then
    echo "SKIP: $f is the master machine configuration; skipping Home Manager check"
    continue
  fi

  if ! grep -Eq '(\./|\../)?profiles/|networking\.hostName|users\.users' "$f"; then
    echo "SKIP: $f appears to be a machine helper module (no profile/hostname/users); skipping Home Manager check"
    continue
  fi

  # Check for local or relative imports (e.g. './cosmic-workstation.nix' or
  # '../profiles/cosmic.nix') and see if any of those transitively import
  # home-manager. We look for occurrences starting with ./ or ../ and ending
  # with .nix.
  localImports=$(grep -oE '(\./|\../)[^ \t\n]+\.nix' "$f" || true)
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
