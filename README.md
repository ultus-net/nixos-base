# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

A **modular NixOS flake** for building desktop workstations with 9 popular desktop environments plus a minimal headless base profile. Designed for easy installation, testing, and customization.

## 📋 Prerequisites

Before installing:
- **NixOS installation media** - Download the latest [NixOS ISO](https://nixos.org/download.html)
- **Basic Linux knowledge** - Comfortable with terminal commands and disk partitioning
- **Hardware requirements** - 20GB+ disk space, 4GB+ RAM (varies by desktop)
- **Internet connection** - Required for downloading packages
- **UEFI firmware** - Most modern systems (BIOS installation requires manual adaptation)

**⚠️ IMPORTANT:** After installation, you MUST set user passwords manually:
```bash
sudo passwd username  # Replace 'username' with your actual username
```
This flake uses empty passwords by default for security reasons.

## 🗺️ Installation Path Decision Tree

Choose your installation method based on your experience level:

```
┌─ Are you NEW to NixOS or want the EASIEST method?
│
├─ YES → Use Calamares GUI Installer
│         └─ See: QUICK-INSTALL-CALAMARES.md
│         └─ ✅ Graphical, point-and-click
│         └─ ✅ No manual partitioning needed
│         └─ ⏱️  ~20 minutes total
│
└─ NO  → Are you comfortable with manual partitioning?
          │
          ├─ YES → Manual Installation
          │        └─ See: INSTALL.md
          │        └─ 🎯 Full control over disk layout
          │        └─ 🔒 Can use LUKS encryption
          │        └─ ⏱️  ~15 minutes (if experienced)
          │
          └─ NO  → Quick Script Installation (Coming Soon)
                   └─ Use: scripts/partition-drive.sh
                   └─ ⚡ Automatic partitioning
                   └─ 🔧 Still manual but guided

Already installed? Want to switch desktops?
└─ See: USAGE.md (Desktop Switching section)
```

**Still unsure?** 
- **Never used Linux before?** → Calamares method
- **Used Ubuntu/Fedora before?** → Manual installation
- **NixOS expert?** → Create custom machine config

## ⚡ Quick Start

**🎯 EASIEST METHOD: Use Calamares GUI installer first, then apply your config!**

See **[QUICK-INSTALL-CALAMARES.md](documentation/QUICK-INSTALL-CALAMARES.md)** for the simplest installation.

**Manual method:**
```bash
# Clone during NixOS installation
cd /mnt && git clone https://github.com/ultus-net/nixos-base

# Install with your chosen desktop
nixos-install --flake /mnt/nixos-base#gnome-workstation
```

**Available desktops:** COSMIC, GNOME, KDE Plasma, Cinnamon, XFCE, MATE, Budgie, Pantheon, LXQt, or base-server (headless)

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK-INSTALL-CALAMARES.md](documentation/QUICK-INSTALL-CALAMARES.md)** | ⭐ EASIEST: GUI install first, apply config after |
| **[QUICK-INSTALL-COSMIC.md](documentation/QUICK-INSTALL-COSMIC.md)** | Quick tower.nix COSMIC installation |
| **[FEATURES.md](documentation/FEATURES.md)** | Available desktop environments and optional modules |
| **[INSTALL.md](documentation/INSTALL.md)** | Complete installation guide from scratch |
| **[USAGE.md](documentation/USAGE.md)** | Day-to-day usage, switching desktops, creating machines |
| **[ARCHITECTURE.md](documentation/ARCHITECTURE.md)** | Repository structure and design philosophy |
| **[TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)** | Common issues and solutions |
| **[CONTRIBUTING.md](documentation/CONTRIBUTING.md)** | How to contribute new features |
| **[SECRETS.md](documentation/SECRETS.md)** | Secrets management guide |

### Module Documentation

- **[modules/README.md](modules/README.md)** - Complete module documentation
- **[profiles/README.md](profiles/README.md)** - Desktop environment profiles
- **[machines/README.md](machines/README.md)** - Machine configuration guide
- **[home/README.md](home/README.md)** - Home Manager setup
- **[scripts/README.md](scripts/README.md)** - Helper scripts

## 🎨 Desktop Environments

| Desktop | Profile | Display | Weight | Description |
|---------|---------|---------|--------|-------------|
| COSMIC | `cosmic-workstation` | Wayland | Medium | System76's Rust-based modern desktop |
| GNOME | `gnome-workstation` | Wayland | Medium | Modern GNOME Shell with extensions |
| KDE | `kde-workstation` | Wayland/X11 | Heavy | Feature-rich Plasma 6 with all apps |
| Cinnamon | `cinnamon-workstation` | X11 | Medium | Linux Mint's flagship, traditional UI |
| XFCE | `xfce-workstation` | X11 | Light | Lightweight & highly customizable |
| MATE | `mate-workstation` | X11 | Light | Classic GNOME 2 fork, stable & fast |
| Budgie | `budgie-workstation` | X11 | Light | Modern & elegant, Solus-originated |
| Pantheon | `pantheon-workstation` | X11 | Medium | elementary OS desktop, macOS-like |
| LXQt | `lxqt-workstation` | X11 | Light | Lightweight Qt desktop, very minimal |
| Base | `base-server` | None | Minimal | Headless server (no GUI) |

**Weight:** Light (<2GB RAM), Medium (2-4GB), Heavy (4GB+)

See [FEATURES.md](documentation/FEATURES.md) for detailed information.

## ✨ Key Features

- **9 Desktop Environments** - COSMIC, GNOME, KDE, and more
- **Modular Design** - Enable only what you need (gaming, multimedia, development)
- **Modern CLI Tools** - fzf, zoxide, eza, bat, ripgrep, delta, starship
- **Home Manager** - User environment management included
- **VM Testing** - Test configurations before deploying
- **CI/CD Pipeline** - Automated validation and boot tests
- **Security Defaults** - SSH keys only, firewall enabled, no root login

## 🚀 Common Tasks

### Install a Desktop
```bash
nixos-install --flake /mnt/nixos-base#gnome-workstation
```

### Switch Desktops
```bash
sudo nixos-rebuild switch --flake .#kde-workstation
```

### Test in a VM
```bash
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm
./result/bin/run-*-vm
```

### Update System
```bash
nix flake update
sudo nixos-rebuild switch --flake .#your-config
```

See [USAGE.md](documentation/USAGE.md) for complete usage guide.

## 🎯 First 5 Minutes After Install

After rebooting into your new system:

1. **Set your password** (REQUIRED):
   ```bash
   sudo passwd hunter  # Replace 'hunter' with your username
   ```

2. **Verify system**:
   ```bash
   nixos-version
   ```

3. **Connect to WiFi** (if needed):
   ```bash
   nmtui  # Text UI for NetworkManager
   ```

4. **Update your system**:
   ```bash
   cd /etc/nixos  # Or wherever you cloned nixos-base
   nix flake update
   sudo nixos-rebuild switch --flake .#your-desktop-workstation
   ```

5. **Customize your username** (Optional):
   - Edit `machines/example-machine.nix` or your machine config
   - Replace "hunter" with your username throughout
   - Update `home/hunter.nix` → `home/yourusername.nix`
   - Rebuild with: `sudo nixos-rebuild switch --flake .#your-config`

## 📦 Optional Modules

Enable additional functionality as needed:

- **Multimedia** - VLC, GIMP, OBS, video editing
- **Gaming** - Steam, Lutris, MangoHUD, Proton
- **Development** - Languages, build tools, formatters
- **Containers** - Podman, distrobox, Kubernetes tools
- **Virtualization** - QEMU, libvirt, virt-manager
- **Sysadmin** - Backups, monitoring, diagnostics
- **Laptop** - Battery optimization, touchpad config
- **Wallpapers** - Official NixOS wallpaper collection with auto-rotation (enabled by default)

See [FEATURES.md](documentation/FEATURES.md) for module details.

## 🏗️ Repository Structure

```
nixos-base/
├── flake.nix              # Main flake configuration
├── modules/               # Reusable NixOS modules
├── profiles/              # Desktop environment profiles
├── machines/              # Machine-specific configurations
├── home/                  # Home Manager configurations
├── scripts/               # Helper scripts
└── .github/               # CI/CD workflows
```

See [ARCHITECTURE.md](documentation/ARCHITECTURE.md) for design details.

## 🧪 CI/CD Pipeline

Comprehensive testing ensures configurations work before deployment:

- ✅ All 10 configurations build and evaluate
- ✅ Module syntax validation
- ✅ Security scanning for secrets
- ✅ Home Manager validation
- 🏷️ VM boot tests (manual only - add `test-vm-boot` label to PR)

See [.github/CI-CD-GUIDE.md](.github/CI-CD-GUIDE.md) for pipeline documentation.

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](documentation/CONTRIBUTING.md) for guidelines.

## 📝 License

This project is open source. See individual files for licensing information.

## 🆘 Need Help?

- Check [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md) for common issues
- Review [USAGE.md](documentation/USAGE.md) for detailed examples
- Read [FAQ.md](documentation/FAQ.md) for common questions
- Open an issue for bugs or questions
- Join the NixOS community channels

## 🙏 Acknowledgments

Built on the shoulders of:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [COSMIC Desktop](https://github.com/pop-os/cosmic-epoch)
- The entire Nix community
