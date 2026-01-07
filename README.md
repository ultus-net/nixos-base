# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

A **modular NixOS flake** for building desktop workstations with 9 popular desktop environments plus a minimal headless base profile. Designed for easy installation, testing, and customization.

## ⚡ Quick Start

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
| **[INSTALL.md](INSTALL.md)** | Complete installation guide from scratch |
| **[USAGE.md](USAGE.md)** | Day-to-day usage, switching desktops, creating machines |
| **[FEATURES.md](FEATURES.md)** | Available desktop environments and optional modules |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Repository structure and design philosophy |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Common issues and solutions |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | How to contribute new features |
| **[SECRETS.md](SECRETS.md)** | Secrets management guide |

### Module Documentation

- **[modules/README.md](modules/README.md)** - Complete module documentation
- **[profiles/README.md](profiles/README.md)** - Desktop environment profiles
- **[machines/README.md](machines/README.md)** - Machine configuration guide
- **[home/README.md](home/README.md)** - Home Manager setup
- **[scripts/README.md](scripts/README.md)** - Helper scripts

## 🎨 Desktop Environments

| Desktop | Profile | Description |
|---------|---------|-------------|
| COSMIC | `cosmic-workstation` | System76's Rust/Wayland desktop |
| GNOME | `gnome-workstation` | Modern GNOME Shell |
| KDE | `kde-workstation` | Feature-rich Plasma 6 |
| Cinnamon | `cinnamon-workstation` | Linux Mint flagship |
| XFCE | `xfce-workstation` | Lightweight & traditional |
| MATE | `mate-workstation` | Classic GNOME 2 fork |
| Budgie | `budgie-workstation` | Modern & elegant |
| Pantheon | `pantheon-workstation` | elementary OS desktop |
| LXQt | `lxqt-workstation` | Lightweight Qt desktop |
| Base | `base-server` | Minimal headless (no desktop) |

See [FEATURES.md](FEATURES.md) for detailed information.

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

See [USAGE.md](USAGE.md) for complete usage guide.

## 📦 Optional Modules

Enable additional functionality as needed:

- **Multimedia** - VLC, GIMP, OBS, video editing
- **Gaming** - Steam, Lutris, MangoHUD, Proton
- **Development** - Languages, build tools, formatters
- **Containers** - Podman, distrobox, Kubernetes tools
- **Virtualization** - QEMU, libvirt, virt-manager
- **Sysadmin** - Backups, monitoring, diagnostics
- **Laptop** - Battery optimization, touchpad config

See [FEATURES.md](FEATURES.md) for module details.

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

See [ARCHITECTURE.md](ARCHITECTURE.md) for design details.

## 🧪 CI/CD Pipeline

Comprehensive testing ensures configurations work before deployment:

- ✅ All 10 configurations build and evaluate
- ✅ VM boot tests verify base-server and xfce-workstation actually boot
- ✅ Module syntax validation
- ✅ Security scanning for secrets
- ✅ Home Manager validation

VM tests run on `main` branch or with `test-vm-boot` PR label.

See [.github/CI-CD-GUIDE.md](.github/CI-CD-GUIDE.md) for pipeline documentation.

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is open source. See individual files for licensing information.

## 🆘 Need Help?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [USAGE.md](USAGE.md) for detailed examples
- Open an issue for bugs or questions
- Join the NixOS community channels

## 🙏 Acknowledgments

Built on the shoulders of:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [COSMIC Desktop](https://github.com/pop-os/cosmic-epoch)
- The entire Nix community
