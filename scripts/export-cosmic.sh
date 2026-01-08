#!/usr/bin/env bash
set -euo pipefail

# Export current COSMIC / GNOME settings for inspection or reproduction.
# Writes files to the repository `exports/` directory (which is gitignored).

TS=$(date +%Y%m%d-%H%M%S)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$REPO_ROOT/exports/cosmic-settings-$TS"
mkdir -p "$DEST"
echo "exported at $TS" > "$DEST/README.txt"

echo "Dumping dconf..."
if command -v dconf >/dev/null 2>&1; then
  dconf dump / > "$DEST/dconf_dump_root.dconf" 2>/dev/null || true
fi

[ -f "$HOME/.config/dconf/user" ] && cp "$HOME/.config/dconf/user" "$DEST/" || true

echo "Dumping gsettings..."
if command -v gsettings >/dev/null 2>&1; then
  gsettings list-schemas > "$DEST/gsettings_schemas.txt" 2>/dev/null || true
  gsettings list-recursively > "$DEST/gsettings_all_list_recursively.txt" 2>/dev/null || true
fi

echo "Copying COSMIC/GNOME configs..."
cp -r "$HOME/.config/gtk-4.0" "$DEST/" 2>/dev/null || true
cp -r "$HOME/.config/cosmic" "$DEST/" 2>/dev/null || true
cp -r "$HOME/.config/gnome-shell" "$DEST/" 2>/dev/null || true
cp -r "$HOME/.local/share/gnome-shell" "$DEST/" 2>/dev/null || true

[ -f "$HOME/.config/monitors.xml" ] && mkdir -p "$DEST/.config" && cp "$HOME/.config/monitors.xml" "$DEST/.config/" || true

echo "Archiving to exports/...tar.gz"
ARCHIVE="$REPO_ROOT/exports/cosmic-settings-$TS.tar.gz"
tar -C "$REPO_ROOT/exports" -czf "$ARCHIVE" "$(basename "$DEST")"

echo "Created $ARCHIVE"
echo "Done."
