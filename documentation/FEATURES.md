# Features

## 🎨 Desktop Environments

This flake provides **9 popular desktop environments** plus a **headless base profile**:

| Desktop | Profile | Description |
|---------|---------|-------------|
| **Base** | `base-server` | Minimal headless configuration (no desktop, perfect for servers/VMs) |
| **COSMIC** | `cosmic-workstation` | System76's next-gen Rust/Wayland desktop (requires nixos-cosmic) |
| **GNOME** | `gnome-workstation` | Modern GNOME Shell experience |
| **KDE Plasma** | `kde-workstation` | Feature-rich Qt desktop (Plasma 6) |
| **Cinnamon** | `cinnamon-workstation` | Linux Mint's flagship desktop |
| **XFCE** | `xfce-workstation` | Lightweight, traditional desktop |
| **MATE** | `mate-workstation` | GNOME 2 fork, classic experience |
| **Budgie** | `budgie-workstation` | Modern & elegant (Solus Linux) |
| **Pantheon** | `pantheon-workstation` | elementary OS desktop |
| **LXQt** | `lxqt-workstation` | Lightweight Qt desktop |

Install any desktop with:
```bash
nixos-install --flake /mnt/nixos-base#<profile>
```

See `profiles/README.md` for detailed desktop environment documentation.

## 📦 Optional Modules

### Multimedia
VLC, GIMP, ffmpeg, OBS Studio, Kdenlive, Blender, Inkscape, and more.

**Enable:**
```nix
imports = [ ../modules/multimedia.nix ];
multimedia.enable = true;
```

### Gaming
Steam, Lutris, MangoHUD, GameMode, Proton optimization, and compatibility tools.

**Enable:**
```nix
imports = [ ../modules/gaming.nix ];
gaming.enable = true;
```

### Development
Multiple language runtimes (Python, Node.js, Go, Rust), build tools, formatters, linters, and development utilities.

**Enable:**
```nix
imports = [ ../modules/development.nix ];
development.enable = true;
```

### Containers
Podman, distrobox, docker-compose, Kubernetes tools (kubectl, k9s, helm).

**Enable:**
```nix
imports = [ ../modules/containers.nix ];
containers.enable = true;
```

### Virtualization
QEMU, libvirt, virt-manager, VM management tools.

**Enable:**
```nix
imports = [ ../modules/virtualization.nix ];
virtualization.enable = true;
```

### Sysadmin
Backup tools (restic, rclone, borg), network diagnostics, hardware monitoring, system administration utilities.

**Enable:**
```nix
imports = [ ../modules/sysadmin.nix ];
sysadmin.enable = true;
```

### Laptop
Battery optimization (TLP), power management, touchpad configuration.

**Enable:**
```nix
imports = [ ../modules/laptop.nix ];
laptop.enable = true;
```

### Wallpapers
Complete collection of official NixOS wallpapers from `nixos-artwork` with automatic rotation support for all desktop environments.

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

## 🛠️ Quality of Life

### Modern CLI Tools
All profiles include modern replacements for traditional Unix tools:

- **fzf** - Fuzzy finder for command history and file search
- **zoxide** - Smarter cd command that learns your habits
- **eza** - Modern replacement for ls with colors and icons
- **bat** - Cat with syntax highlighting and Git integration
- **ripgrep** - Faster grep written in Rust
- **fd** - Simpler, faster alternative to find
- **lazygit** - Terminal UI for Git
- **delta** - Syntax-highlighting pager for Git diffs
- **starship** - Minimal, fast shell prompt

### Home Manager Integration
Pre-configured Home Manager setup for managing user dotfiles and configurations.

See `home/README.md` for Home Manager documentation.

## 🔒 Security Defaults

- SSH enabled with key-based authentication only
- Firewall enabled by default
- Root login disabled
- Password authentication disabled
- Fail2ban available in security module

See `SECRETS.md` for secrets management options.

## 🧹 Automatic Cleanup

Systemd timers automatically:
- Keep last 3 system generations
- Garbage collect store paths older than 14 days
- Maintain a small rollback window while preventing disk bloat

Override these defaults in your machine configuration if needed.

## 📊 Snapshot Retention

The default configuration keeps:
- **3 system generations** for rollback capability
- **14 days** of store paths before garbage collection

This balances rollback safety with disk space management.
