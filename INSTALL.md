<!-- Installation and deployment guide for the nixos-base flake -->
# Installation guide — nixos-base

This guide shows how to install a NixOS system from the `nixos-base` flake in
this repository on a fresh VM or device. It includes a non-encrypted UEFI example,
an optional LUKS-encrypted root example, post-install verification steps, and
troubleshooting notes relevant to this repo.

Prerequisites and assumptions
- You're using UEFI (adjust partitioning for BIOS if necessary).
- You have a NixOS live ISO and a working network in the installer environment.
-- This repository exposes a NixOS system configuration named `cosmic-workstation` in the
  top-level flake (replace with the flake output you want if different).
- Commands that interact with flakes use the `nix --extra-experimental-features
  'nix-command flakes'` prefix where required.

Quick overview
- Boot NixOS live ISO and confirm network.
- Partition and format the disk (UEFI example provided).
- Clone the repo into `/mnt` so the flake path is local to the target root.
- Run `nixos-install --flake` to install from the flake.

Contents
- 1) Boot & network
- 2) Partitioning & mounting (UEFI)
- 3) Clone the repo
- 4) Install from the flake
- 5) Optional: LUKS-encrypted root
- 6) Post-install verification
- 7) Enabling flakes permanently
- 8) Using helper scripts & nested flakes
- 9) Troubleshooting

1) Boot the NixOS installer and confirm network

Boot the NixOS live ISO and get to a shell. Ensure networking is up (DHCP typical):

```bash
ping -c 3 8.8.8.8
```

2) Partition and format disks (UEFI example)

This example creates a 512 MiB EFI system partition and the rest as an ext4
root partition. Replace `/dev/sda` with your target device.

```bash
# Device to use
DISK=/dev/sda

# Create GPT and partitions
parted --script "$DISK" mklabel gpt
parted --script "$DISK" mkpart primary 1MiB 513MiB
parted --script "$DISK" set 1 boot on
parted --script "$DISK" mkpart primary 513MiB 100%

EFI="${DISK}1"
ROOT="${DISK}2"

# Format
mkfs.fat -F32 "$EFI"
mkfs.ext4 -L nixos-root "$ROOT"

# Mount
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot
```

Notes:
- Add a swap partition or swapfile if you need swap.
- For BIOS/legacy boot you need a BIOS boot partition and different bootloader steps.

3) Clone the repository into the installer environment

Clone the repository into the target root so that the flake can be referenced
locally from `/mnt`.

```bash
git clone https://github.com/ultus-net/nixos-base.git /mnt/nixos-base

# Quick diagnostic (enable features for this command)
nix --extra-experimental-features 'nix-command flakes' flake show /mnt/nixos-base
```

Alternative: reference the GitHub-hosted flake directly:
```bash
nix --extra-experimental-features 'nix-command flakes' flake show github:ultus-net/nixos-base
```

4) Install NixOS from the flake

Run `nixos-install` using the flake output you want to install. The example
below installs `cosmic-workstation` from the repository clone.

```bash
  nix --extra-experimental-features 'nix-command flakes' \
  nixos-install --root /mnt --flake /mnt/nixos-base#cosmic-workstation
```

Notes:
- `--root /mnt` points the installer at the mounted target filesystem.
- If your flake defines other host outputs (for example a nested GNOME flake),
  refer to them appropriately. For nested flakes within the repo the easiest
  approach is to use top-level outputs exposed by `flake.nix` — otherwise use
  an explicit local path such as `/mnt/nixos-base/./flakes/gnome#gnome-workstation`.

5) Optional: LUKS-encrypted root (brief)

This is a minimal flow for encrypting the root partition with LUKS. Replace the
device names as appropriate.

```bash
ROOT_PART=/dev/sda2
cryptsetup luksFormat "$ROOT_PART"
cryptsetup open "$ROOT_PART" cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

When using LUKS you must ensure your NixOS configuration contains the
appropriate `boot.initrd.luks.devices` and `fileSystems` entries so the system
can unlock the root on boot. If you're not comfortable editing the flake
directly, you can `nixos-generate-config --root /mnt` and adapt the generated
configuration file (for example `machines/configuration.nix`) before running
`nixos-install`.

6) Post-install: reboot and verify

After a successful install, reboot the machine:

```bash
reboot
```

On first boot:
- Log in as the user configured by the flake (or as root if you set a root
  password).
- Check the active system generation and NixOS version:

```bash
sudo nixos-version
sudo nix-env -q --profile /nix/var/nix/profiles/system
```

7) Enabling flakes permanently

To avoid passing experimental flags manually each time, add the following to
your NixOS configuration (for example the flake's machine module or
`machines/configuration.nix`):

```nix
nix.extraOptions = ''
  extra-experimental-features = nix-command flakes
'';
```

If the flake's host configuration already sets `nix.extraOptions`, you don't
need to change anything.

8) Using the included helper script and nested flakes

This repo provides `scripts/switch-host.sh` to build or switch to a host.
Examples (run from the repo root):

```bash
# Build local flake host (non-root)
./scripts/switch-host.sh .#cosmic-workstation

# Switch to the GNOME nested flake (requires root for switching)
sudo ./scripts/switch-host.sh ./flakes/gnome#gnome-workstation
```

Note: use `./flakes/gnome#...` (with `./`) to reference nested flakes on disk and
avoid registry lookups.

9) Troubleshooting

- "experimental Nix feature 'nix-command' is disabled":
  * Use `nix --extra-experimental-features 'nix-command flakes' <command>` or
    add `nix.extraOptions` to your NixOS configuration as shown above.

- "cannot find flake 'flake:flakes/gnome' in the flake registries":
  * Use a local path for nested flakes (`./flakes/gnome`) or point to the
    repository path on disk (e.g., `/mnt/nixos-base`).

- Flake evaluation errors during install:
  * Run `nix --extra-experimental-features 'nix-command flakes' flake show
    /mnt/nixos-base --json` in the installer to inspect outputs.
  * Build key outputs locally with `nix build` to get detailed errors.

- EFI/bootloader problems:
  * Make sure `/mnt/boot` is mounted and the NixOS flake includes a boot
    loader configuration (most host outputs do). If not, adapt `configuration.nix`.

Quick command summary (copy/paste)

```bash
# Partition & format (UEFI, non-encrypted example)
DISK=/dev/sda
parted --script "$DISK" mklabel gpt
parted --script "$DISK" mkpart primary 1MiB 513MiB
parted --script "$DISK" set 1 boot on
parted --script "$DISK" mkpart primary 513MiB 100%
mkfs.fat -F32 ${DISK}1
mkfs.ext4 -L nixos-root ${DISK}2
mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

# Clone repo and install
git clone https://github.com/ultus-net/nixos-base.git /mnt/nixos-base
  nix --extra-experimental-features 'nix-command flakes' \
  nixos-install --root /mnt --flake /mnt/nixos-base#cosmic-workstation
reboot
```

If you'd like, I can add a ready-to-run install script for the live
environment (both encrypted and non-encrypted variants) and/or expand the LUKS
section to include `crypttab`/dracut-like integration if you prefer that flow.

---
End of installation guide.
