#!/usr/bin/env bash
# valve-theme-setup.sh - Automated setup for Valve/Half-Life KDE theme
# Inspired by: https://www.reddit.com/r/unixporn/comments/1qbn8wd/kde_obsession_with_valve/

set -e

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
        if [ -d Steamed/Steamed ]; then
            cp -r Steamed/Steamed ~/.local/share/plasma/desktoptheme/
            echo -e "${GREEN}✓ Steamed Plasma Theme installed${NC}"
        else
            echo -e "${RED}✗ Theme directory structure unexpected${NC}"
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

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 What was installed:${NC}"
echo "  ✓ Half-Life background wallpaper"
echo "  ✓ Steam 2003 GTK theme"
echo "  ✓ Steamed color scheme"
echo "  ✓ Steamed Plasma Theme"
echo "  ✓ GTK configuration files"
echo ""
echo -e "${YELLOW}📝 Next steps - Complete theme setup in System Settings:${NC}"
echo ""
echo -e "${BLUE}1. Get Additional Themes (if not auto-installed):${NC}"
echo "   System Settings → Appearance → Window Decorations"
echo "   → Get New Window Decorations → Search: 'Steamed'"
echo ""
echo "   System Settings → Appearance → Icons"
echo "   → Get New Icons → Search: 'yet-another-monochrome'"
echo ""
echo -e "${BLUE}2. Apply Themes:${NC}"
echo "   System Settings → Appearance → Colors → 'Steamed'"
echo "   System Settings → Appearance → Plasma Style → 'Steamed'"
echo "   System Settings → Appearance → Icons → 'yet-another-monochrome-icon-set'"
echo "   System Settings → Appearance → Cursors → 'KDE Classic'"
echo "   System Settings → Appearance → Application Style → 'MS Windows 9x'"
echo ""
echo -e "${BLUE}3. Set Wallpaper:${NC}"
echo "   Right-click Desktop → Configure Desktop and Wallpaper"
echo "   → Add Image → ~/Pictures/Wallpapers/half-life-background.png"
echo ""
echo -e "${BLUE}4. Configure Fonts:${NC}"
echo "   System Settings → Appearance → Fonts"
echo "   → Set all to 'Trebuchet MS' or 'DejaVu Sans' 10pt"
echo ""
echo -e "${BLUE}5. Optional - Browser Theme:${NC}"
echo "   Firefox: https://addons.mozilla.org/en-US/firefox/addon/half-life-console/"
echo ""
echo -e "${BLUE}6. Optional - Steam Theme:${NC}"
echo "   Steam Millennium: https://steambrew.app/theme?id=8YTvx3fAAfwQSu6MNOfH"
echo ""
echo -e "${YELLOW}📖 Full documentation: documentation/KDE-VALVE-THEME-GUIDE.md${NC}"
echo ""
echo -e "${GREEN}Enjoy your Valve-themed KDE desktop! 🎮${NC}"
