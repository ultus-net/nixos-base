#!/usr/bin/env bash

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick (magick) is not installed."
    exit 1
fi

LOGO="wallpapers/nixos-logo.png"

# Function to generate wallpaper
generate_wallpaper() {
    local NAME=$1
    local BG_COLOR=$2
    local C1=$3 # Darker tone
    local C2=$4 # Lighter tone
    local HEIGHT=$5
    local PAD=$6
    
    # Calculate dimensions
    # Aspect Ratio 1.155
    local LOGO_WIDTH=$(( HEIGHT * 1155 / 1000 ))
    local CELL_W=$((LOGO_WIDTH + PAD))
    local CELL_H=$((HEIGHT + PAD))
    
    # Canvas Size for Seamless Tiling (Flat-Top Hex Pattern)
    local CANVAS_W=$(( (CELL_W * 3) / 2 ))
    local CANVAS_H=$(( CELL_H ))
    
    local TEMP_RESIZED="temp_logo_${NAME}_resized.png"
    local TEMP_COLORED="temp_logo_${NAME}_colored.png"
    local TEMP_TILE="temp_tile_${NAME}.png"
    local OUTPUT="wallpapers/nixos-honeycomb-${NAME}.png"

    echo "Generating $NAME: Size ${LOGO_WIDTH}x${HEIGHT}, Padding $PAD (Canvas ${CANVAS_W}x${CANVAS_H})..."

    # 1. Resize
    magick "$LOGO" -resize "${LOGO_WIDTH}x${HEIGHT}!" "$TEMP_RESIZED"
    
    # 2. Recolor (Two-Tone)
    magick "$TEMP_RESIZED" \
        -colorspace gray \
        -channel RGB +level-colors "$C1","$C2" +channel \
        "$TEMP_COLORED"

    # 3. Create Seamless Tile
    # Logic: Draw Center -> Roll (Offset to corners) -> Draw Center
    local ROLLER_X=$((CANVAS_W / 2))
    local ROLLER_Y=$((CANVAS_H / 2))

    magick -size "${CANVAS_W}x${CANVAS_H}" xc:"$BG_COLOR" \
        "$TEMP_COLORED" -gravity center -composite \
        -roll "+${ROLLER_X}+${ROLLER_Y}" \
        "$TEMP_COLORED" -gravity center -composite \
        "$TEMP_TILE"
        
    # 4. Tile to Wallpaper Size
    magick -size 1920x1080 tile:"$TEMP_TILE" "$OUTPUT"

    # Cleanup
    rm -f "$TEMP_RESIZED" "$TEMP_COLORED" "$TEMP_TILE"
}

# --- Variants ---

# High Density / Zoomed Out Config
# Height: 24 (Tiny logos)
# Padding: 5 (Distinct channels)

# 1. Nord Dark
generate_wallpaper "nord-dark" "#2e3440" "#434C5E" "#88C0D0" 24 5

# 2. Nord Light
generate_wallpaper "nord-light" "#eceff4" "#D8DEE9" "#2E3440" 24 5

# 3. Nord Frost
generate_wallpaper "nord-frost" "#5e81ac" "#434C5E" "#ECEFF4" 24 5

# 4. Nord Red
generate_wallpaper "nord-red" "#bf616a" "#2E3440" "#ECEFF4" 24 5

# 5. Dracula
generate_wallpaper "dracula" "#282a36" "#44475a" "#ff79c6" 24 5

# 6. Solarized Dark
generate_wallpaper "solarized-dark" "#002b36" "#073642" "#2aa198" 24 5

# 7. Gruvbox Dark
generate_wallpaper "gruvbox-dark" "#282828" "#af3a03" "#fbf1c7" 24 5

# 8. NixOS Brand (brand blue hues)
# Using brand-like darker -> lighter blue pair and a dark navy background
# Use official NixOS logo gradient colors from the Branding site
# dark tone -> light tone derived from the SVG gradients
generate_wallpaper "nixos-brand" "#07263b" "#3e5993" "#77b6e1" 24 5

echo "Done!"
