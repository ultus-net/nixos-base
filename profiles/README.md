README — profiles/
===================

Purpose
-------
This directory holds desktop "profiles": small NixOS module fragments that
describe a desktop environment, related packages, and profile-level features
(QoL, developer packages, desktop services). Profiles do NOT include 
machine-specific settings like `networking.hostName`, `fileSystems`, or 
`boot.loader` configurations.

**IMPORTANT:** These profiles are **incomplete system configurations**. They
cannot be installed directly without adding:
1. `fileSystems` configuration (usually from `hardware-configuration.nix`)
2. At least one user account
3. A hostname

For a complete example, see `machines/example-machine.nix`.

Available Desktops
------------------

### Wayland-First Desktops

- **cosmic.nix** — System76 COSMIC desktop (Rust-based, cutting-edge)
  - Requires nixos-cosmic flake input
  - Binary cache: https://cosmic.cachix.org/
  - Modern Wayland compositor written in Rust
  
- **gnome.nix** — GNOME Shell (modern, popular)
  - GTK-based, excellent Wayland support
  - Great for laptops with touchpad gestures
  
- **gnome-dev.nix** — GNOME optimized for developers
  - Same as GNOME but with developer-focused QoL
  - Includes development tools and packages

- **kde.nix** — KDE Plasma 6 (feature-rich, Qt-based)
  - Highly customizable
  - Excellent Wayland support
  - Wide range of applications

### Traditional X11 Desktops (with Wayland options)

- **cinnamon.nix** — Cinnamon (Linux Mint flagship)
  - Familiar Windows-like interface
  - Stable and user-friendly
  
- **xfce.nix** — XFCE (lightweight, fast)
  - Low resource usage
  - Traditional desktop paradigm
  - Optional Wayland session available
  
- **mate.nix** — MATE (GNOME 2 fork)
  - Classic desktop experience
  - Lightweight and stable
  - Optional Wayland session via Wayfire

- **budgie.nix** — Budgie (Solus Linux desktop)
  - Modern and elegant
  - GNOME-based but unique experience
  
- **pantheon.nix** — Pantheon (elementary OS)
  - Beautiful, macOS-inspired design
  - Focused on simplicity and elegance
  - Wayland support
  
- **lxqt.nix** — LXQt (lightweight Qt desktop)
  - Very low resource usage
  - Fast and responsive

Usage
-----
- To use a profile when deploying to hardware, import it from a `machines/`
  entry. For example:

  ```nix
  imports = [ ./configuration.nix ../profiles/cosmic.nix ../modules/common-users.nix ];
  networking.hostName = "my-pc";
  ```

- Profiles are intentionally shareable: you can reuse the same profile across
  many machines.

Notes
-----
- Keep profiles focused on desktop-level concerns: session managers,
  desktop packages, and per-user Home Manager defaults. Avoid embedding
  disk UUIDs, LUKS settings, or bootloader device paths here.
