# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

A modular NixOS flake for desktop workstations, servers, and multiple desktop environments.

## Quick Start

For a graphical installation, see the [Calamares installation guide](documentation/QUICK-INSTALL-CALAMARES.md).

For a manual installation:
```bash
# Clone and install during NixOS installation
cd /mnt && git clone https://github.com/ultus-net/nixos-base
nixos-install --flake /mnt/nixos-base#gnome-workstation
```

After the first boot:
```bash
sudo passwd yourusername  # Set your password (REQUIRED)
```

See [INSTALL.md](documentation/INSTALL.md) for the full installation procedure.

## Desktop Environments

| Desktop | Display | Weight | Description |
|---------|---------|--------|-------------|
| **COSMIC** | Wayland | Medium | System76's Rust-based desktop |
| **GNOME** | Wayland | Medium | GNOME Shell with extensions |
| **KDE** | Wayland/X11 | Heavy | Feature-rich Plasma 6 |
| **Cinnamon** | X11 | Medium | Linux Mint's traditional UI |
| **XFCE** | X11 | Light | Lightweight desktop environment |
| **Hyprland** | Wayland | Light | Dynamic tiling Wayland compositor |
| **Base** | None | Minimal | Headless server |

Switch desktops anytime: `./scripts/switch-desktop.sh cosmic`

## Documentation

### Getting Started
- **[QUICK-INSTALL-CALAMARES.md](documentation/QUICK-INSTALL-CALAMARES.md)** - Graphical installation
- **[INSTALL.md](documentation/INSTALL.md)** - Manual installation
- **[USAGE.md](documentation/USAGE.md)** - Day-to-day usage and examples
- **[FEATURES.md](documentation/FEATURES.md)** - Available desktops and modules

### Advanced Topics
- **[PERFORMANCE.md](documentation/PERFORMANCE.md)** - Gaming and performance tuning
- **[ARCHITECTURE.md](documentation/ARCHITECTURE.md)** - Repository structure and design
- **[TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)** - Common issues and solutions
- **[CONTRIBUTING.md](documentation/CONTRIBUTING.md)** - How to contribute

### Module Docs
- [modules/](modules/README.md) - Audio, gaming, virtualization, etc.
- [profiles/](profiles/README.md) - Desktop environment profiles
- [machines/](machines/README.md) - Machine configuration guide
- [home/](home/README.md) - Home Manager setup
- [scripts/](scripts/README.md) - Helper scripts

## Features

- Modular profiles for gaming, multimedia, development, and desktop environments
- CLI tooling including fzf, zoxide, eza, bat, ripgrep, and starship
- Home Manager integration for user configuration
- Optional gaming and system performance settings
- VM tests and automated flake validation

## Contributing

See [CONTRIBUTING.md](documentation/CONTRIBUTING.md) for development and contribution guidelines.

## Support

- [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md) - Common issues
- [FAQ.md](documentation/FAQ.md) - Frequently asked questions
- GitHub Issues - Bug reports and questions

This configuration uses [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), and [COSMIC Desktop](https://github.com/pop-os/cosmic-epoch).
