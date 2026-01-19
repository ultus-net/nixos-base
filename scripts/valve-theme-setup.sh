#!/usr/bin/env bash
# valve-theme-setup.sh - Complete automated setup and application for Valve/Half-Life KDE theme
# Inspired by: https://www.reddit.com/r/unixporn/comments/1qbn8wd/kde_obsession_with_valve/

set -e

# Function to set KDE configuration
kwriteconfig() {
    local file=$1
    local group=$2
    local key=$3
    local value=$4
    
    if command -v kwriteconfig6 &> /dev/null; then
        kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
    elif command -v kwriteconfig5 &> /dev/null; then
        kwriteconfig5 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Valve/Half-Life KDE Theme Setup              ║${NC}"
echo -e "${BLUE}║  Inspired by r/unixporn Valve theme posts     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Create directories
echo -e "${YELLOW}→ Creating theme directories...${NC}"
mkdir -p ~/.local/share/color-schemes
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.local/share/aurorae/themes
mkdir -p ~/.local/share/icons
mkdir -p ~/.themes
mkdir -p ~/Pictures/Wallpapers
echo -e "${GREEN}✓ Directories created${NC}"

# Download Half-Life wallpaper
echo ""
echo -e "${YELLOW}→ Downloading Half-Life background wallpaper...${NC}"
cd ~/Pictures/Wallpapers

if [ -f "half-life-background.png" ]; then
    echo -e "${BLUE}ℹ Wallpaper already exists, skipping...${NC}"
else
    if command -v wget &> /dev/null; then
        wget -q https://developer.valvesoftware.com/w/images/3/3a/Half-Life_-_Background.png \
          -O half-life-background.png && \
          echo -e "${GREEN}✓ Wallpaper downloaded using wget${NC}" || \
          echo -e "${RED}✗ Failed to download with wget${NC}"
    elif command -v curl &> /dev/null; then
        curl -sL https://developer.valvesoftware.com/w/images/3/3a/Half-Life_-_Background.png \
          -o half-life-background.png && \
          echo -e "${GREEN}✓ Wallpaper downloaded using curl${NC}" || \
          echo -e "${RED}✗ Failed to download with curl${NC}"
    else
        echo -e "${RED}✗ Neither wget nor curl found. Please install one.${NC}"
    fi
fi

# Clone Steam 2003 GTK theme
echo ""
echo -e "${YELLOW}→ Downloading Steam 2003 GTK theme...${NC}"
if [ -d ~/.themes/Steam-2003 ]; then
    echo -e "${BLUE}ℹ GTK theme already installed, skipping...${NC}"
else
    cd ~/Downloads
    if git clone --depth 1 https://github.com/TheHawkcrestKnight/Steam-2003 2>/dev/null; then
        cp -r Steam-2003 ~/.themes/
        echo -e "${GREEN}✓ Steam 2003 GTK theme installed${NC}"
        
        # Configure GTK to use the theme
        mkdir -p ~/.config/gtk-3.0
        cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=Steam-2003
gtk-icon-theme-name=yet-another-monochrome-icon-set
gtk-font-name=Trebuchet MS 10
gtk-cursor-theme-name=KDE-Classic
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
EOF
        echo -e "${GREEN}✓ GTK settings configured${NC}"
    else
        echo -e "${RED}✗ Failed to clone GTK theme repository${NC}"
        echo -e "${YELLOW}  You can manually download from: https://github.com/TheHawkcrestKnight/Steam-2003${NC}"
    fi
fi

# Create Steamed color scheme if it doesn't exist
echo ""
echo -e "${YELLOW}→ Creating Steamed color scheme template...${NC}"
cat > ~/.local/share/color-schemes/Steamed.colors << 'EOF'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=66,66,66
BackgroundNormal=60,60,60
DecorationFocus=204,85,0
DecorationHover=230,97,0
ForegroundActive=204,85,0
ForegroundInactive=136,136,136
ForegroundLink=204,85,0
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=224,224,224
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=204,85,0
BackgroundNormal=204,85,0
DecorationFocus=204,85,0
DecorationHover=230,97,0
ForegroundActive=255,255,255
ForegroundInactive=224,224,224
ForegroundLink=255,128,0
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=255,255,255
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Tooltip]
BackgroundAlternate=42,42,42
BackgroundNormal=42,42,42
DecorationFocus=204,85,0
DecorationHover=230,97,0
ForegroundActive=204,85,0
ForegroundInactive=136,136,136
ForegroundLink=204,85,0
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=224,224,224
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:View]
BackgroundAlternate=50,50,50
BackgroundNormal=42,42,42
DecorationFocus=204,85,0
DecorationHover=230,97,0
ForegroundActive=204,85,0
ForegroundInactive=136,136,136
ForegroundLink=204,85,0
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=224,224,224
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Window]
BackgroundAlternate=50,50,50
BackgroundNormal=42,42,42
DecorationFocus=204,85,0
DecorationHover=230,97,0
ForegroundActive=204,85,0
ForegroundInactive=136,136,136
ForegroundLink=204,85,0
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=224,224,224
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[General]
ColorScheme=Steamed
Name=Steamed
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=42,42,42
activeBlend=224,224,224
activeForeground=224,224,224
inactiveBackground=26,26,26
inactiveBlend=136,136,136
inactiveForeground=136,136,136
EOF

echo -e "${GREEN}✓ Steamed color scheme created${NC}"

# Install Steamed Plasma Theme from GitHub
echo ""
echo -e "${YELLOW}→ Installing Steamed Plasma Theme from GitHub...${NC}"
if [ -d ~/.local/share/plasma/desktoptheme/Steamed ]; then
    echo -e "${BLUE}ℹ Steamed Plasma Theme already installed, skipping...${NC}"
else
    cd ~/Downloads
    if git clone --depth 1 https://github.com/UNATCO-JCDenton/Steamed 2>/dev/null; then
        # Check various possible directory structures
        if [ -d Steamed/Steamed ]; then
            cp -r Steamed/Steamed ~/.local/share/plasma/desktoptheme/
            echo -e "${GREEN}✓ Steamed Plasma Theme installed${NC}"
        elif [ -d Steamed/desktoptheme ]; then
            cp -r Steamed/desktoptheme/* ~/.local/share/plasma/desktoptheme/
            echo -e "${GREEN}✓ Steamed Plasma Theme installed${NC}"
        elif [ -f Steamed/metadata.desktop ]; then
            # The repo itself is the theme directory
            cp -r Steamed ~/.local/share/plasma/desktoptheme/
            echo -e "${GREEN}✓ Steamed Plasma Theme installed${NC}"
        else
            echo -e "${YELLOW}⚠ Theme structure not recognized, trying manual copy...${NC}"
            # Try to find any folder with metadata.desktop
            THEME_DIR=$(find Steamed -name "metadata.desktop" -type f -exec dirname {} \; | head -1)
            if [ -n "$THEME_DIR" ]; then
                THEME_NAME=$(basename "$THEME_DIR")
                cp -r "$THEME_DIR" ~/.local/share/plasma/desktoptheme/
                echo -e "${GREEN}✓ Steamed Plasma Theme installed as $THEME_NAME${NC}"
            else
                echo -e "${RED}✗ Could not find theme in repository${NC}"
                echo -e "${YELLOW}  You can download manually from: https://store.kde.org/p/2225120${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ Could not clone theme repository${NC}"
        echo -e "${YELLOW}  You can download manually from: https://store.kde.org/p/2225120${NC}"
    fi
fi

# Refresh KDE cache
echo ""
echo -e "${YELLOW}→ Refreshing KDE theme cache...${NC}"
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6 --noincremental 2>/dev/null && \
        echo -e "${GREEN}✓ KDE cache refreshed${NC}" || \
        echo -e "${YELLOW}⚠ Could not refresh cache (may need to log out/in)${NC}"
else
    echo -e "${YELLOW}⚠ kbuildsycoca6 not found, cache not refreshed${NC}"
fi

# ============================================================================
# AUTOMATIC THEME APPLICATION
# ============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Applying Valve/Half-Life Theme Automatically ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Backup existing configurations
BACKUP_DIR=~/.config/kde-backup-$(date +%Y%m%d-%H%M%S)
echo -e "${YELLOW}→ Creating backup of current KDE configuration...${NC}"
mkdir -p "$BACKUP_DIR"
for file in kdeglobals plasmarc kwinrc kcminputrc plasma-org.kde.plasma.desktop-appletsrc; do
    if [ -f ~/.config/$file ]; then
        cp ~/.config/$file "$BACKUP_DIR/"
    fi
done
echo -e "${GREEN}✓ Backup created at: $BACKUP_DIR${NC}"

# Apply Steamed Color Scheme
echo ""
echo -e "${YELLOW}→ Applying Steamed color scheme...${NC}"
kwriteconfig kdeglobals General ColorScheme "Steamed"
kwriteconfig kdeglobals General Name "Steamed"

# Apply colors directly
kwriteconfig kdeglobals "Colors:Button" BackgroundNormal "60,60,60"
kwriteconfig kdeglobals "Colors:Button" ForegroundNormal "224,224,224"
kwriteconfig kdeglobals "Colors:Selection" BackgroundNormal "204,85,0"
kwriteconfig kdeglobals "Colors:Selection" ForegroundNormal "255,255,255"
kwriteconfig kdeglobals "Colors:View" BackgroundNormal "42,42,42"
kwriteconfig kdeglobals "Colors:View" ForegroundNormal "224,224,224"
kwriteconfig kdeglobals "Colors:Window" BackgroundNormal "42,42,42"
kwriteconfig kdeglobals "Colors:Window" ForegroundNormal "224,224,224"
kwriteconfig kdeglobals "Colors:Window" DecorationFocus "204,85,0"

# Apply Window Decoration colors
kwriteconfig kdeglobals WM activeBackground "42,42,42"
kwriteconfig kdeglobals WM activeForeground "224,224,224"
kwriteconfig kdeglobals WM inactiveBackground "26,26,26"
kwriteconfig kdeglobals WM inactiveForeground "136,136,136"

echo -e "${GREEN}✓ Color scheme applied${NC}"

# Apply Plasma Theme
echo -e "${YELLOW}→ Applying Steamed Plasma theme...${NC}"
kwriteconfig plasmarc Theme name "Steamed"
echo -e "${GREEN}✓ Plasma theme applied${NC}"

# Apply Icon Theme
echo -e "${YELLOW}→ Setting icon theme...${NC}"
if [ -d ~/.local/share/icons/yet-another-monochrome-icon-set ] || [ -d ~/.icons/yet-another-monochrome-icon-set ]; then
    kwriteconfig kdeglobals Icons Theme "yet-another-monochrome-icon-set"
    echo -e "${GREEN}✓ Icon theme set to yet-another-monochrome-icon-set${NC}"
else
    echo -e "${YELLOW}⚠ yet-another-monochrome-icon-set not found${NC}"
    echo -e "${YELLOW}  Download from: System Settings → Icons → Get New Icons${NC}"
fi

# Apply Cursor Theme
echo -e "${YELLOW}→ Setting cursor theme...${NC}"
kwriteconfig kdeglobals Icons cursorTheme "KDE-Classic"
kwriteconfig kcminputrc Mouse cursorTheme "KDE-Classic"
kwriteconfig kcminputrc Mouse cursorSize "24"
echo -e "${GREEN}✓ Cursor theme applied${NC}"

# Apply Widget Style
echo -e "${YELLOW}→ Setting widget style...${NC}"
kwriteconfig kdeglobals KDE widgetStyle "Breeze"
kwriteconfig kdeglobals General widgetStyle "Breeze"
echo -e "${GREEN}✓ Widget style applied${NC}"

# Apply Window Decorations
echo -e "${YELLOW}→ Setting window decorations...${NC}"
if [ -d ~/.local/share/aurorae/themes/Steamed ]; then
    kwriteconfig kwinrc "org.kde.kdecoration2" library "org.kde.kwin.aurorae"
    kwriteconfig kwinrc "org.kde.kdecoration2" theme "__aurorae__svg__Steamed"
    echo -e "${GREEN}✓ Window decorations set to Steamed${NC}"
else
    kwriteconfig kwinrc "org.kde.kdecoration2" library "org.kde.kdecoration2"
    kwriteconfig kwinrc "org.kde.kdecoration2" theme "Breeze"
    echo -e "${YELLOW}⚠ Steamed window decoration not found, using Breeze${NC}"
    echo -e "${YELLOW}  Download from: System Settings → Window Decorations → Get New${NC}"
fi

# Apply Fonts
echo -e "${YELLOW}→ Configuring fonts...${NC}"
if fc-list 2>/dev/null | grep -qi "trebuchet"; then
    FONT_FAMILY="Trebuchet MS"
    echo -e "${GREEN}  Using Trebuchet MS${NC}"
else
    FONT_FAMILY="DejaVu Sans"
    echo -e "${YELLOW}  Trebuchet MS not found, using DejaVu Sans${NC}"
fi

kwriteconfig kdeglobals General font "$FONT_FAMILY,10,-1,5,50,0,0,0,0,0"
kwriteconfig kdeglobals General fixed "Monospace,10,-1,5,50,0,0,0,0,0"
kwriteconfig kdeglobals General smallestReadableFont "$FONT_FAMILY,8,-1,5,50,0,0,0,0,0"
kwriteconfig kdeglobals General toolBarFont "$FONT_FAMILY,10,-1,5,50,0,0,0,0,0"
kwriteconfig kdeglobals General menuFont "$FONT_FAMILY,10,-1,5,50,0,0,0,0,0"
kwriteconfig kdeglobals WM activeFont "$FONT_FAMILY,10,-1,5,75,0,0,0,0,0"
echo -e "${GREEN}✓ Fonts configured${NC}"

# Set wallpaper
echo -e "${YELLOW}→ Setting wallpaper...${NC}"
WALLPAPER_PATH="$HOME/Pictures/Wallpapers/half-life-background.png"
if [ -f "$WALLPAPER_PATH" ]; then
    if command -v plasma-apply-wallpaperimage &> /dev/null; then
        plasma-apply-wallpaperimage "$WALLPAPER_PATH" 2>/dev/null && \
            echo -e "${GREEN}✓ Wallpaper applied${NC}" || \
            echo -e "${YELLOW}⚠ Could not apply wallpaper automatically${NC}"
    else
        # Use qdbus to set wallpaper
        if command -v qdbus &> /dev/null || command -v qdbus-qt5 &> /dev/null; then
            QDBUS_CMD=$(command -v qdbus || command -v qdbus-qt5)
            $QDBUS_CMD org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allDesktops = desktops();
                for (i=0;i<allDesktops.length;i++) {
                    d = allDesktops[i];
                    d.wallpaperPlugin = 'org.kde.image';
                    d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                    d.writeConfig('Image', 'file://$WALLPAPER_PATH');
                }
            " 2>/dev/null && echo -e "${GREEN}✓ Wallpaper applied${NC}" || \
                echo -e "${YELLOW}⚠ Could not apply wallpaper${NC}"
        else
            echo -e "${YELLOW}⚠ No wallpaper setter found${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Wallpaper not found at: $WALLPAPER_PATH${NC}"
fi

# Restart KDE components
echo ""
echo -e "${YELLOW}→ Restarting KDE components to apply changes...${NC}"

if pgrep -x plasmashell > /dev/null 2>&1; then
    # Restart plasmashell
    killall plasmashell 2>/dev/null || true
    sleep 2
    (kstart5 plasmashell 2>/dev/null || kstart plasmashell 2>/dev/null || plasmashell 2>/dev/null) &
    disown
    echo -e "${GREEN}✓ Plasmashell restarted${NC}"
    
    # Reconfigure KWin
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null && \
            echo -e "${GREEN}✓ KWin reconfigured${NC}" || true
    elif command -v qdbus-qt5 &> /dev/null; then
        qdbus-qt5 org.kde.KWin /KWin reconfigure 2>/dev/null && \
            echo -e "${GREEN}✓ KWin reconfigured${NC}" || true
    fi
else
    echo -e "${YELLOW}⚠ Not in Plasma session, components not restarted${NC}"
    echo -e "${YELLOW}  Please log out and log back in for changes to take effect${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}Theme Setup and Application Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 What was done:${NC}"
echo "  ✓ Half-Life background wallpaper downloaded"
echo "  ✓ Steam 2003 GTK theme installed"
echo "  ✓ Steamed color scheme created and applied"
echo "  ✓ Steamed Plasma theme installed and applied"
echo "  ✓ Colors configured (Valve orange/gray)"
echo "  ✓ Fonts configured ($FONT_FAMILY 10pt)"
echo "  ✓ Cursor theme set (KDE Classic)"
echo "  ✓ Wallpaper set"
echo "  ✓ KDE components restarted"
echo ""
echo -e "${YELLOW}📝 Optional manual steps:${NC}"
echo "  1. Download window decorations: System Settings → Window Decorations"
echo "     → Get New → Search: 'Steamed'"
echo ""
echo "  2. Download icons: System Settings → Icons → Get New"
echo "     → Search: 'yet-another-monochrome'"
echo ""
echo "  3. Firefox theme: https://addons.mozilla.org/firefox/addon/half-life-console/"
echo ""
echo "  4. Steam theme: https://steambrew.app/theme?id=8YTvx3fAAfwQSu6MNOfH"
echo ""
echo -e "${BLUE}💾 Backup saved at:${NC} $BACKUP_DIR"
echo -e "${BLUE}📖 Full documentation:${NC} documentation/KDE-VALVE-THEME-GUIDE.md"
echo ""
echo -e "${GREEN}Enjoy your Valve-themed KDE desktop! 🎮${NC}"
