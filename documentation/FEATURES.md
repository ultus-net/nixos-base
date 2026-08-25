# Features

## Desktop Environments

This flake provides **6 desktop environments** plus a **headless base profile**:

### Desktop Environment Details

#### Base Server (`base-server`)
**Display Server:** None (headless)  
**Resource Usage:** Minimal (~500MB RAM)  
**Use Cases:** Servers, containers, VMs, network appliances

**What's Included:**
- Essential CLI tools (htop, btop, git, vim, tmux)
- Modern CLI replacements (ripgrep, eza, bat, delta, fzf)
- SSH server with hardened security
- NetworkManager for network configuration
- ZRAM compressed swap

#### COSMIC (`cosmic-workstation`)
**Display Server:** Wayland  
**Resource Usage:** Medium (~3GB RAM)  
**Use Cases:** Wayland desktops, System76 hardware

**What's Included:**
- COSMIC compositor and shell (Rust-based)
- COSMIC applications (Files, Terminal, Settings, etc.)
- All base packages + Firefox, VS Code, Alacritty
- PipeWire audio stack
- Wayland screen sharing support

#### GNOME (`gnome-workstation`)
**Display Server:** Wayland (X11 fallback)  
**Resource Usage:** Medium (~3.5GB RAM)  
**Use Cases:** Wayland desktops, touchpad-oriented workflows

**What's Included:**
- GNOME Shell with essential extensions
- GNOME apps (Files, Terminal, Calendar, Contacts, etc.)
- Firefox, VS Code, GNOME Text Editor
- Wayland + XWayland for compatibility
- PipeWire audio with noise cancellation

#### KDE Plasma (`kde-workstation`)
**Display Server:** Wayland (X11 available)  
**Resource Usage:** Heavy (~4GB RAM)  
**Use Cases:** Configurable Qt-based desktops

**What's Included:**
- KDE Plasma 6 desktop
- Full KDE app suite (Dolphin, Konsole, Kate, Okular, Gwenview, etc.)
- Discover software center
- KWallet password manager
- Firefox, VS Code
- Extensive customization options

#### Cinnamon (`cinnamon-workstation`)
**Display Server:** X11  
**Resource Usage:** Medium (~2.5GB RAM)  
**Use Cases:** Traditional desktop layouts

**What's Included:**
- Cinnamon desktop environment
- Nemo file manager
- Core Cinnamon applications
- Firefox, VS Code
- Traditional menu and panel layout
- PipeWire audio stack

#### XFCE (`xfce-workstation`)
**Display Server:** X11  
**Resource Usage:** Light (~1.5GB RAM)  
**Use Cases:** Lightweight desktop installations

**What's Included:**
- XFCE desktop environment
- Thunar file manager
- XFCE Terminal
- Firefox, VS Code
- Lightweight desktop environment
- PipeWire audio stack

#### Hyprland (`hyprland-workstation`)
**Display Server:** Wayland  
**Resource Usage:** Light (~2GB RAM)  
**Use Cases:** Dynamic tiling workflows

**What's Included:**
- Hyprland dynamic tiling compositor
- Waybar status bar
- Wofi application launcher
- Kitty terminal
- Firefox, VS Code
- Advanced tiling features
- PipeWire audio stack


### Quick Comparison

| Desktop | Display | Weight | Typical Use |
|---------|---------|--------|-------------|
| **Base** | None | Minimal | Servers and headless systems |
| **COSMIC** | Wayland | Medium | Wayland desktop |
| **GNOME** | Wayland | Medium | General-purpose desktop |
| **KDE** | Both | Heavy | Configurable Qt desktop |
| **Cinnamon** | X11 | Medium | Traditional desktop layout |
| **XFCE** | X11 | Light | Lightweight desktop |
| **Hyprland** | Wayland | Light | Dynamic tiling |

Install any desktop with:
```bash
nixos-install --flake /mnt/nixos-base#<profile>
```

See `profiles/README.md` for detailed desktop environment documentation.

## Optional Modules

### Multimedia (`multimedia.nix`)
Media creation and editing tools.

**What's Included:**
- **Video:** VLC, MPV, OBS Studio, Kdenlive, Handbrake, FFmpeg
- **Image:** GIMP, Inkscape, Krita, Darktable, ImageMagick
- **Audio:** Audacity, Ardour, EasyEffects
- **3D:** Blender
- **Utilities:** youtube-dl, mediainfo

**Enable:**
```nix
imports = [ ../modules/multimedia.nix ];
multimedia.enable = true;
```

### Gaming (`gaming.nix`)
Gaming compatibility layers and performance tools.

**What's Included:**
- **Platforms:** Steam (with Proton), Lutris, Heroic Games Launcher
- **Performance:** MangoHUD, GameMode, vkBasalt
- **Tools:** Protontricks, Protonup-Qt, Wine
- **Optimization:** Kernel tweaks for gaming
- **Hardware:** 32-bit GPU drivers, gamepad support

**Enable:**
```nix
imports = [ ../modules/gaming.nix ];
gaming.enable = true;
```

### Development (`development.nix`)
Development tools and language runtimes.

**What's Included:**
- **Languages:** Python 3, Node.js 22, Go, Rust (rustup)
- **Version Managers:** nvm equivalent via Nix
- **Build Tools:** CMake, make, pkg-config, just
- **Formatters:** black, ruff, prettier, stylua, shfmt
- **Linters:** eslint, shellcheck, pylint
- **Package Managers:** pnpm, bun, cargo
- **Tools:** jq, yq, httpie, postman

**Enable:**
```nix
imports = [ ../modules/development.nix ];
development.enable = true;
```

### Containers (`containers.nix`)
Container and Kubernetes tools.

**What's Included:**
- **Runtime:** Docker, docker-compose
- **Tools:** distrobox (run any Linux distro)
- **Kubernetes:** kubectl, k9s (TUI), helm
- **Building:** buildah, skopeo
- **Utilities:** docker-compose syntax support

**Enable:**
```nix
imports = [ ../modules/containers.nix ];
containers.enable = true;
```

### Virtualization (`virtualization.nix`)
Virtualization tools with GUI management.

**What's Included:**
- **Hypervisor:** QEMU/KVM with hardware acceleration
- **Management:** virt-manager (GUI), virsh (CLI)
- **Library:** libvirt with networking
- **Tools:** virt-viewer, virt-install
- **Features:** USB passthrough, shared folders, snapshots

**Enable:**
```nix
imports = [ ../modules/virtualization.nix ];
virtualization.enable = true;
```

### Sysadmin (`sysadmin.nix`)
System administration tools.

**What's Included:**
- **Backups:** restic, rclone, borgbackup, duplicity
- **Monitoring:** htop, btop, iotop, iftop, nethogs
- **Network:** nmap, tcpdump, wireshark, netcat, iperf
- **Disk:** gparted, smartmontools, ncdu
- **Hardware:** lshw, usbutils, pciutils, dmidecode
- **Performance:** sysstat, stress-ng
- **Logs:** lnav (log navigator)

**Enable:**
```nix
imports = [ ../modules/sysadmin.nix ];
sysadmin.enable = true;
```

### Laptop (`laptop.nix`)
Laptop-specific power and hardware management.

**What's Included:**
- **Power:** TLP with optimized settings
- **Battery:** Battery charge thresholds (if supported)
- **Display:** Auto-brightness, screen timeout
- **Input:** Touchpad gestures and palm detection
- **Sleep:** Suspend/hibernate optimization
- **Monitoring:** powerstat, powertop

**Enable:**
```nix
imports = [ ../modules/laptop.nix ];
laptop.enable = true;
```

### Wallpapers
NixOS wallpapers from `nixos-artwork` with automatic rotation support for desktop environments.

**Enable:**
```nix
imports = [ ../modules/wallpapers.nix ];
machines.wallpapers.enable = true;
machines.wallpapers.rotationInterval = 300;  # seconds
```

**Includes:**
- 40+ official wallpapers (binary series, Catppuccin themes, nineish retro, 3D renders)
- Automatic rotation configured per desktop environment
- System-wide installation accessible to all users

**Note:** Enabled by default in all desktop profiles. Home Manager automatically symlinks wallpapers to `~/.wallpapers`.

See `modules/README.md` for complete module documentation.

## Command-Line Tools

All profiles include these command-line tools:

- **fzf** - Fuzzy finder for command history and file search
- **zoxide** - Directory navigation based on usage history
- **eza** - `ls` alternative with colors and icons
- **bat** - File viewer with syntax highlighting and Git integration
- **ripgrep** - Recursive text search
- **fd** - `find` alternative
- **lazygit** - Terminal UI for Git
- **delta** - Syntax-highlighting pager for Git diffs
- **starship** - Minimal, fast shell prompt

### Home Manager Integration
Pre-configured Home Manager setup for managing user dotfiles and configurations.

See `home/README.md` for Home Manager documentation.

## Security Defaults

- SSH enabled with key-based authentication only
- Firewall enabled by default
- Root login disabled
- Password authentication disabled
- Fail2ban available in security module

See `SECRETS.md` for secrets management options.

## Automatic Cleanup

Systemd timers automatically:
- Keep last 3 system generations
- Garbage collect store paths older than 14 days
- Maintain a small rollback window while preventing disk bloat

Override these defaults in your machine configuration if needed.

## Generation Retention

The default configuration keeps:
- **3 system generations** for rollback capability
- **14 days** of store paths before garbage collection
