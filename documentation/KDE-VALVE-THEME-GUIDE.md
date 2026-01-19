# KDE Valve/Half-Life Theme Setup Guide

This guide will help you recreate the nostalgic Valve/Steam/Half-Life themed KDE desktop inspired by [this Reddit post](https://www.reddit.com/r/unixporn/comments/1qbn8wd/kde_obsession_with_valve/).

## Preview

The theme features:
- Classic Windows 9x-style window decorations
- Valve/Steam orange and gray color scheme
- Retro Half-Life interface aesthetics
- Monochrome icon set
- Classic KDE cursor

## Configuration

### 1. Enable Valve Theme Support in NixOS

Edit your machine configuration to enable the Valve theme option:

```nix
# In your machine configuration (e.g., machines/tower.nix)
kde = {
  enable = true;
  valveTheme.enable = true;  # Adds required theming packages
};
```

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .#tower
```

### 2. Download Required Theme Components

#### Get the Steamed Theme
The "Steamed" theme is a custom theme that gives the Valve/Steam look. You'll need to download it manually:

1. **Color Scheme (Steamed):**
   - Search KDE Store for "Steamed" color scheme
   - Or create manually in System Settings -> Colors

2. **Plasma Style (Steamed):**
   - **KDE Store:** https://store.kde.org/p/2225120
   - **GitHub:** https://github.com/UNATCO-JCDenton/Steamed
   ```bash
   # Download from KDE Store via System Settings
   # System Settings -> Appearance -> Plasma Style -> Get New Plasma Styles
   # Search for "Steamed"
   ```

3. **Window Decorations (Steamed):**
   - Available from the same theme package or separately
   ```bash
   # System Settings -> Appearance -> Window Decorations -> Get New Window Decorations
   # Search for "Steamed"
   ```

4. **Icons (yet-another-monochrome-icon-set):**
   ```bash
   # System Settings -> Appearance -> Icons -> Get New Icons
   # Search for "yet-another-monochrome"
   ```

5. **Cursor Theme (KDE Classic):**
   - Should be pre-installed with KDE
   - System Settings -> Appearance -> Cursors -> KDE Classic

### 3. Manual Theme Downloads (Alternative Method)

If the KDE Store doesn't work or you prefer manual installation:

```bash
# Create theme directories
mkdir -p ~/.local/share/color-schemes
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.local/share/aurorae/themes
mkdir -p ~/.local/share/icons

# Install Steamed Plasma Theme from GitHub
cd ~/Downloads
git clone https://github.com/UNATCO-JCDenton/Steamed
cp -r Steamed/Steamed ~/.local/share/plasma/desktoptheme/

# You can also download themes from:
# - GitHub repositories
# - store.kde.org
# - pling.com/browse/cat/104/ (KDE themes)
```

### 4. Configure GTK Theme (Redmond97 Fork - Steam 2003)

For GTK applications to match:

```bash
# Clone the Steam 2003 GTK theme
cd ~/Downloads
git clone https://github.com/TheHawkcrestKnight/Steam-2003

# Install it
mkdir -p ~/.themes
cp -r Steam-2003 ~/.themes/

# Set GTK theme in System Settings
# System Settings -> Appearance -> Application Style -> Configure GNOME/GTK Application Style
```

### 5. Download Half-Life Wallpaper

```bash
# Download the classic Half-Life background
cd ~/Pictures
wget https://developer.valvesoftware.com/w/images/3/3a/Half-Life_-_Background.png -O half-life-background.png

# Set it as wallpaper
# Right-click desktop -> Configure Desktop and Wallpaper -> Add Image
```

### 6. Install Trebuchet MS Font

The original setup uses Trebuchet MS at 10pt. On NixOS:

```nix
# Add to your configuration
fonts.packages = with pkgs; [
  vistafonts  # Includes Trebuchet MS (proprietary, requires acceptance)
  # Or use open alternative:
  dejavu_fonts
  liberation_ttf
];
```

### 7. Apply Theme Settings

After downloading all components, configure through System Settings:

#### Colors & Theme
1. **System Settings -> Appearance -> Colors**
   - Select "Steamed" color scheme

2. **System Settings -> Appearance -> Application Style**
   - Widget Style: Select "MS Windows 9x" or "kvantum"
   - If using Kvantum, configure Steamed theme in kvantum manager

3. **System Settings -> Appearance -> Plasma Style**
   - Select "Steamed"

4. **System Settings -> Appearance -> Window Decorations**
   - Select "Steamed"
   - Configure titlebar buttons as needed

5. **System Settings -> Appearance -> Icons**
   - Select "yet-another-monochrome-icon-set"

6. **System Settings -> Appearance -> Cursors**
   - Select "KDE Classic"

#### Fonts
**System Settings -> Appearance -> Fonts**
- General: Trebuchet MS, 10pt
- Fixed width: Consolas or Courier New, 10pt
- Small: Trebuchet MS, 8pt
- Toolbar: Trebuchet MS, 10pt
- Menu: Trebuchet MS, 10pt
- Window title: Trebuchet MS, 10pt Bold

## Additional Customizations

### Panel Configuration
Make the panel look more like the old Steam interface:
1. Right-click panel -> Enter Edit Mode
2. Adjust panel height (try 36-44px)
3. Add widgets that match the Steam aesthetic
4. Consider using a floating panel with rounded corners

### Konsole Theme
Match your terminal to the theme:
```bash
# System Settings -> Konsole
# Or edit ~/.local/share/konsole/*.profile
# Set color scheme to match Valve orange/gray palette
```

### Firefox Theme
Install the Half-Life Console theme mentioned in the Reddit post:
- Visit: https://addons.mozilla.org/en-US/firefox/addon/half-life-console/

### Steam Client Theme
Install Steam Millennium with OldSteam theme:
- Visit: https://steambrew.app/theme?id=8YTvx3fAAfwQSu6MNOfH

## Quick Theme Installation Script

Here's a helper script to automate some downloads:

```bash
#!/usr/bin/env bash
# valve-theme-setup.sh

set -e

echo "Setting up Valve/Half-Life KDE theme..."

# Create directories
mkdir -p ~/.local/share/color-schemes
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.local/share/aurorae/themes
mkdir -p ~/.local/share/icons
mkdir -p ~/.themes
mkdir -p ~/Pictures/Wallpapers

# Download wallpaper
echo "Downloading Half-Life wallpaper..."
cd ~/Pictures/Wallpapers
wget -q https://developer.valvesoftware.com/w/images/3/3a/Half-Life_-_Background.png \
  -O half-life-background.png 2>/dev/null || \
  curl -s https://developer.valvesoftware.com/w/images/3/3a/Half-Life_-_Background.png \
  -o half-life-background.png

echo "✓ Wallpaper downloaded to ~/Pictures/Wallpapers/"

# Clone GTK theme
if [ ! -d ~/.themes/Steam-2003 ]; then
    echo "Downloading Steam 2003 GTK theme..."
    cd ~/Downloads
    git clone https://github.com/TheHawkcrestKnight/Steam-2003 2>/dev/null || true
    if [ -d Steam-2003 ]; then
        cp -r Steam-2003 ~/.themes/
        echo "✓ GTK theme installed"
    fi
fi

echo ""
echo "Setup complete! Now:"
echo "1. Go to System Settings -> Appearance"
echo "2. Download themes from KDE Store:"
echo "   - Plasma Style: 'Steamed' (https://store.kde.org/p/2225120)"
echo "   - Window Decorations: 'Steamed'"
echo "   - Icons: 'yet-another-monochrome-icon-set'"
echo "3. Apply downloaded themes"
echo "4. Set wallpaper from ~/Pictures/Wallpapers/"
echo "5. Configure fonts to Trebuchet MS 10pt"
```

Save this as `scripts/valve-theme-setup.sh` and run:
```bash
chmod +x scripts/valve-theme-setup.sh
./scripts/valve-theme-setup.sh
```

## Manual Color Scheme Creation

If you can't find the "Steamed" color scheme, create it manually:

**System Settings -> Appearance -> Colors -> Edit Color Scheme**

Use these approximate values based on Valve's Steam/HL1 interface:
- **Window Background:** `#3c3c3c` (dark gray)
- **Text:** `#e0e0e0` (light gray)
- **Highlight:** `#cc5500` (Valve orange)
- **Active Titlebar:** `#2a2a2a` (darker gray)
- **Inactive Titlebar:** `#1a1a1a` (darkest gray)

## Troubleshooting

### Themes Not Appearing
If downloaded themes don't appear in System Settings:
```bash
# Refresh KDE's theme cache
kbuildsycoca6 --noincremental
```

### GTK Apps Don't Match Theme
Make sure you've set the GTK theme:
```bash
# Check current GTK settings
cat ~/.config/gtk-3.0/settings.ini

# Should contain:
# [Settings]
# gtk-theme-name=Steam-2003
```

### Fonts Look Wrong
Ensure fonts are installed and font cache is updated:
```bash
fc-cache -fv
fc-list | grep -i trebuchet
```

## Resources

- **Original Reddit Post:** https://www.reddit.com/r/unixporn/comments/1qbn8wd/kde_obsession_with_valve/
- **KDE Store:** https://store.kde.org/
- **Steam 2003 GTK Theme:** https://github.com/TheHawkcrestKnight/Steam-2003
- **Valve Assets:** https://developer.valvesoftware.com/
- **Steam Millennium Themes:** https://steambrew.app/

## See Also

- [FEATURES.md](FEATURES.md) - Other KDE features available in this config
- [USAGE.md](USAGE.md) - General usage instructions
- Related Reddit posts:
  - [KDE Old school Valve/Steam feelings](https://www.reddit.com/r/unixporn/comments/1pgjvey/kde_old_school_valvesteam_feelings/)
  - [KDE Valve Themed KDE](https://www.reddit.com/r/unixporn/comments/1q0skya/kde_valve_themed_kde/)
  - [XFCE Valve Theme](https://www.reddit.com/r/unixporn/comments/1pbl5x5/xfce_valve_theme/)
