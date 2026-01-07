# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

This repository is a **starter NixOS flake** you can use to install a working
desktop machine with minimal effort. It’s designed to be **desktop-agnostic**:
desktop-specific bits live under `profiles/`, while machine defaults live under
`machines/`.

If you're completely new to NixOS, start here:

1) `INSTALL.md` — step-by-step install from the NixOS live ISO
2) `machines/example-machine.nix` — a template you can copy for your device
3) `profiles/` — choose your desktop environment (9 options available!)

Need help? Check `TROUBLESHOOTING.md` for common issues and solutions.

## Available Desktop Environments

This flake provides **9 popular desktop environments** plus a **headless base profile** for servers:

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

Example desktop: `nixos-install --flake /mnt/nixos-base#cosmic-workstation`  
Example server: `nixos-install --flake /mnt/nixos-base#base-server`

## Quick start (new NixOS install)

Most installs follow this flow:

1) Boot the NixOS live ISO
2) Partition + mount to `/mnt`
3) Clone this repo into `/mnt/nixos-base`
4) Generate hardware config with `nixos-generate-config --root /mnt`
5) Run `nixos-install --flake /mnt/nixos-base#<desktop>-workstation`

The full copy/paste commands are in `INSTALL.md`.

## Documentation

- **`INSTALL.md`** — Complete installation guide from scratch
- **`TROUBLESHOOTING.md`** — Common issues and solutions
- **`SECRETS.md`** — Secrets management guide (sops-nix, agenix, etc.)
- **`CONTRIBUTING.md`** — How to contribute new features or desktop environments
- **`modules/README.md`** — Complete module documentation and usage examples
- **`profiles/README.md`** — Desktop environment profiles documentation
- **`machines/README.md`** — Machine configuration guide
- **`home/README.md`** — Home Manager setup
- **`scripts/README.md`** — Helper scripts documentation

## Features

### 🎨 Desktop Environments
9 popular desktop environments plus a minimal headless base profile for servers (COSMIC, GNOME, KDE, Cinnamon, XFCE, MATE, Budgie, Pantheon, LXQt)

### 📦 Optional Modules
- **Multimedia** - VLC, GIMP, ffmpeg, OBS, video editing tools
- **Containers** - Podman, distrobox, Kubernetes tools
- **Sysadmin** - Backup tools (restic, rclone), network diagnostics, hardware monitoring
- **Gaming** - Steam, Lutris, MangoHUD, Proton optimization
- **Virtualization** - QEMU, libvirt, virt-manager
- **Development** - Multiple language runtimes, build tools, formatters

### 🛠️ Quality of Life
Modern CLI tools: fzf, zoxide, eza, bat, ripgrep, lazygit, and more

See `modules/README.md` for complete module documentation.

## Repository layout

## CI/CD Pipeline

This repository includes a **comprehensive GitHub Actions pipeline** that ensures all configurations are valid and bootable:

### 🔍 What Gets Tested
- ✅ **All 10 configurations** (9 desktops + headless) are built and evaluated
- ✅ **VM boot tests** verify systems actually boot and reach multi-user.target
- ✅ **Module validation** ensures all modules can be imported
- ✅ **Security scanning** checks for hardcoded secrets
- ✅ **Home Manager** configurations are validated

### 🎮 VM Boot Testing
The pipeline actually boots VMs for critical configurations to catch issues before deployment:
- `base-server` (headless)
- `gnome-workstation` (GNOME)
- `kde-workstation` (KDE Plasma 6)  
- `xfce-workstation` (XFCE)

VM tests run on all pushes to `main` and can be triggered on PRs with the `test-vm-boot` label.

### 📚 Full Documentation
See `.github/CI-CD-GUIDE.md` for complete pipeline documentation, troubleshooting tips, and best practices.

### 🧪 Local Testing
Run the same checks locally:

```bash
# Quick validation
nix flake check

# Build a specific configuration
nix build .#nixosConfigurations.gnome-workstation.config.system.build.toplevel

# Test VM boot locally
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm
./result/bin/run-*-vm
```

## Repository layout
file; it’s ignored via `.gitignore`.

- `modules/` — small, focused NixOS module fragments (desktop support, common packages,
	development, QoL, etc.). These are intended to be imported into profile or
	machine-specific configurations.
- `profiles/` — example desktop profiles that compose the fragments in `modules/`.
- `machines/` — machine deployment entries that import `machines/configuration.nix`
	and a `profiles/*` file (or `hardware-configuration.nix` produced at install time).
- `flake.nix` — exports dev shells, a Home Manager module and an example NixOS
	configuration called `cosmic-workstation`.

Multiple desktops (single top-level flake)
-----------------------------------------

This repo exposes desktop workstation configurations from the top-level flake.
`cosmic-workstation`, `gnome-workstation`, and `kde-workstation` are available as top-level
outputs so you can reference them like `.#cosmic-workstation`, `.#gnome-workstation`, or `.#kde-workstation`.
This keeps the repository surface area to a single flake and avoids nested
flake duplication.

Refactor & repository layout
----------------------------

Recent refactors split desktop concerns (profiles) from machine deployments.
- `profiles/` contains desktop profiles (COSMIC, GNOME, KDE) — reusable across many machines.
- `machines/` contains machine deployment entries and the master machine defaults in `machines/configuration.nix`.
- `modules/common-users.nix` centralizes per-machine user creation.
- `modules/zram.nix` provides a tunable zram module with an automatic sizing heuristic and compression option.
- Old `hosts/` files were archived to `hosts-deprecated/` during the migration.
  
Note about moved files
----------------------
During a recent refactor some helper modules were moved out of `machines/`
and into `modules/` to make them reusable across profiles and machines. The
following files were moved and the old copies removed:

- `machines/common-users.nix` -> `modules/common-users.nix`
- `machines/zram.nix` -> `modules/zram.nix`

Machine examples and docs now import these from `../modules/...` (see
`machines/example-machine.nix` for an example). This change doesn't affect
the option names exposed by the modules — options still live in the
`machines.*` namespace (for example `machines.zram.*` and `machines.users`).

The CI validation was updated to ensure `profiles/` and `machines/` exist and
to run `./scripts/validate-hosts-home-manager.sh` which checks that profiles
and deployment entries import the Home Manager module appropriately.

Using unstable
--------------

This flake uses the `nixpkgs-unstable` input by default to pick up newer
packages and desktop features. If you prefer a stable channel for a given
machine, create a machine entry that pins `nixpkgs` locally or override the
flake input when building/installing.

Snapshot retention
------------------

To avoid accumulating old generations and GC roots on devices, the machine
master uses a systemd timer that keeps the last **3** system generations and
garbage-collects store paths older than **14 days**. This gives you a small
rollback window while preventing long-term growth.

If you want different behavior per-machine, override the unit/timer or adjust
your machine configuration accordingly.

Security defaults
-----------------

`machines/configuration.nix` enables OpenSSH by default for install/bring-up,
but sets hardened defaults:

- Password authentication disabled
- Keyboard-interactive authentication disabled
- Root login disallowed

Override any of these per-machine if needed.

Helper script
-------------

Use `scripts/switch-host.sh` to build or switch to a host. The script defaults
to the top-level `cosmic-workstation` configuration when no argument is
provided. Examples:

```bash
# Build the default (cosmic) host locally (non-root)
./scripts/switch-host.sh

# Build / switch to GNOME host via the top-level flake (switch requires root)
sudo ./scripts/switch-host.sh .#gnome-workstation

# Build / switch to KDE host via the top-level flake (switch requires root)
sudo ./scripts/switch-host.sh .#kde-workstation
```

CI
--

There's a GitHub Actions workflow at `.github/workflows/flake-check.yml` that
evaluates the top-level flake and the GNOME flake on push and PRs to `main`.
It simply installs Nix and runs `nix flake show` to catch evaluation errors early.

Installation
------------

See `INSTALL.md` for a step-by-step installation and deployment guide (UEFI and
LUKS examples) describing how to install this flake on a fresh VM or device.

## Switching desktops (after install)

The pattern used here is composition: desktop profiles live under `profiles/` and
contain desktop-agnostic pieces plus a small desktop module (for example,
`modules/kde.nix` or `modules/cosmic.nix`). To deploy to a physical device,
create a `machines/<name>.nix` entry that imports `machines/configuration.nix`
and the chosen `profiles/<profile>.nix` file. The flake still exposes the
desktop profiles as top-level NixOS outputs for convenience.

Examples:


Build and switch to the `cosmic-workstation` configuration defined by this flake:

```bash
sudo nixos-rebuild switch --flake .#cosmic-workstation
```

Alternatively, to build or test the KDE example host locally (no switch):

```bash
nix build .#nixosConfigurations.kde-workstation.config.system.build.toplevel
# or
nixos-rebuild build --flake .#kde-workstation
```

Notes
-----

- Add your own machine by creating a file under `machines/` that `imports`
  `machines/configuration.nix` and the profile you want from `profiles/`.
  Use `modules/common-packages.nix` for a desktop-agnostic set of utilities
  and add `modules/kde.nix`, `modules/cosmic.nix`, or other desktop modules
  in the profile.
- The flake exposes desktop profiles as top-level Nix outputs for convenience
	(so `.#cosmic-workstation` still works). For real device installs it's
	recommended to generate and import an installer-produced
	`hardware-configuration.nix` into a `machines/<name>.nix` entry.
- The flake already provides `homeManagerModules` and a `templates/home`
  example you can adapt for user dotfiles.
