# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

A **modular NixOS flake** for building desktop workstations with multiple desktop environments. Designed for easy installation, testing, and customization.

## 🚀 Quick Start

**New to NixOS?** Use the [Calamares GUI installer](documentation/QUICK-INSTALL-CALAMARES.md) - easiest method!

**Experienced users:**
```bash
# Clone and install during NixOS installation
cd /mnt && git clone https://github.com/ultus-net/nixos-base
nixos-install --flake /mnt/nixos-base#gnome-workstation
```

**After first boot:**
```bash
sudo passwd yourusername  # Set your password (REQUIRED)
```

See [INSTALL.md](documentation/INSTALL.md) for complete installation guide.

## 🎨 Desktop Environments

| Desktop | Display | Weight | Description |
|---------|---------|--------|-------------|
| **COSMIC** | Wayland | Medium | System76's Rust-based modern desktop |
| **GNOME** | Wayland | Medium | Modern GNOME Shell with extensions |
| **KDE** | Wayland/X11 | Heavy | Feature-rich Plasma 6 |
| **Cinnamon** | X11 | Medium | Linux Mint's traditional UI |
| **XFCE** | X11 | Light | Lightweight & customizable |
| **Hyprland** | Wayland | Light | Dynamic tiling Wayland compositor |
| **Base** | None | Minimal | Headless server |

Switch desktops anytime: `./scripts/switch-desktop.sh cosmic`

## 📚 Documentation

### Getting Started
- **[QUICK-INSTALL-CALAMARES.md](documentation/QUICK-INSTALL-CALAMARES.md)** - ⭐ Easiest installation method
- **[INSTALL.md](documentation/INSTALL.md)** - Complete manual installation guide
- **[USAGE.md](documentation/USAGE.md)** - Day-to-day usage and examples
- **[FEATURES.md](documentation/FEATURES.md)** - Available desktops and modules

### Advanced Topics
- **[PERFORMANCE.md](documentation/PERFORMANCE.md)** - 🚀 Gaming & performance tuning
- **[ARCHITECTURE.md](documentation/ARCHITECTURE.md)** - Repository structure and design
- **[TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)** - Common issues and solutions
- **[CONTRIBUTING.md](documentation/CONTRIBUTING.md)** - How to contribute

### Module Docs
- [modules/](modules/README.md) - Audio, gaming, virtualization, etc.
- [profiles/](profiles/README.md) - Desktop environment profiles
- [machines/](machines/README.md) - Machine configuration guide
- [home/](home/README.md) - Home Manager setup
- [scripts/](scripts/README.md) - Helper scripts

## ✨ Key Features

- **Modular Design** - Enable only what you need (gaming, multimedia, development)
- **Modern CLI Tools** - fzf, zoxide, eza, bat, ripgrep, starship
- **Home Manager** - User environment management
- **Performance Tuned** - Gaming optimizations, zram, I/O schedulers
- **VM Testing** - Test configs before deploying
- **CI/CD Pipeline** - Automated validation

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](documentation/CONTRIBUTING.md).

## 🆘 Support

- [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md) - Common issues
- [FAQ.md](documentation/FAQ.md) - Frequently asked questions
- GitHub Issues - Bug reports and questions

---

**License**: Open source. See individual files for details.  
**Credits**: Built with [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), and [COSMIC Desktop](https://github.com/pop-os/cosmic-epoch).
