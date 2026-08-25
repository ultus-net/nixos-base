# Profiles

## Purpose
This directory holds desktop "profiles": small NixOS module fragments that
describe a desktop environment, related packages, and profile-level features
(QoL, developer packages, desktop services). Profiles do NOT include 
machine-specific settings like `networking.hostName`, `fileSystems`, or 
`boot.loader` configurations.

These profiles are **incomplete system configurations**. They
cannot be installed directly without adding:
1. `fileSystems` configuration (usually from `hardware-configuration.nix`)
2. At least one user account
3. A hostname

For a complete example, see `machines/example-machine.nix`.

## Available Profiles

### Headless/Server Profile

- **base.nix** - Minimal headless base (no desktop environment)
  - Essential CLI tools and modern replacements
  - Security hardening (firewall, fail2ban, SSH)
  - NetworkManager for network configuration
  - ZRAM compressed swap
  - Suitable for servers, containers, VMs, and headless systems
  - Optional modules include development, containers, sysadmin, and virtualization

### Wayland-First Desktops

- **cosmic.nix** - System76 COSMIC desktop
  - Requires nixos-cosmic flake input
  - Binary cache: https://cosmic.cachix.org/
  - Wayland compositor written in Rust
  
- **gnome.nix** - GNOME Shell
  - GTK-based with Wayland support
  - Supports touchpad gestures
  
- **kde.nix** - KDE Plasma 6 (Qt-based)
  - Highly customizable
  - Wayland support
  - Wide range of applications

### Traditional X11 Desktops (with Wayland options)

- **cinnamon.nix** - Cinnamon
  - Familiar Windows-like interface
  
- **xfce.nix** - XFCE
  - Low resource usage
  - Traditional desktop paradigm
  - Optional Wayland session available
  

## Usage
- To use a profile when deploying to hardware, import it from a `machines/`
  entry. For example:

  ```nix
  imports = [ ./configuration.nix ../profiles/cosmic.nix ../modules/common-users.nix ];
  networking.hostName = "my-pc";
  ```

- Profiles are intentionally shareable: you can reuse the same profile across
  many machines.

## Notes
- Keep profiles focused on desktop-level concerns: session managers,
  desktop packages, and per-user Home Manager defaults. Avoid embedding
  disk UUIDs, LUKS settings, or bootloader device paths here.
