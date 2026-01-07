# Quick Install Guide - COSMIC Workstation (tower.nix)

This is a copy-paste friendly guide for installing NixOS with the COSMIC desktop
using the tower.nix configuration.

## TL;DR - The Fast Track

If you know what you're doing and just want the commands:

```bash
# 1. Boot NixOS live ISO, connect to internet, partition disk
DISK=/dev/sda  # CHANGE THIS!
sudo parted --script "$DISK" mklabel gpt
sudo parted --script "$DISK" mkpart primary 1MiB 513MiB
sudo parted --script "$DISK" set 1 boot on
sudo parted --script "$DISK" mkpart primary 513MiB 100%
sudo mkfs.fat -F32 ${DISK}1
sudo mkfs.ext4 -L nixos-root ${DISK}2
sudo mount ${DISK}2 /mnt
sudo mkdir -p /mnt/boot
sudo mount ${DISK}1 /mnt/boot

# 2. Generate hardware config
sudo nixos-generate-config --root /mnt

# 3. CRITICAL: Add swap to prevent "no space left" errors!
sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# 4. Install directly from GitHub
sudo nixos-install --root /mnt --flake github:ultus-net/nixos-base#tower

# 5. Set root password when prompted, then reboot
sudo reboot

# 6. After boot: login as root, set user password
passwd hunter
```

---

## What You'll Get
- COSMIC Desktop (System76's new Rust-based desktop)
- Full gaming setup (Steam, Lutris, Heroic, MangoHud)
- Multimedia tools (OBS, Kdenlive, Audacity, GIMP, etc.)
- Virtualization (VirtualBox, virt-manager)
- Container support (Docker, Podman)
- User "hunter" with sudo access

---

## Step 1: Boot the NixOS Live ISO

Boot from your NixOS installation USB/ISO and wait for the desktop to load.
Open a terminal.

---

## Step 2: Connect to the Internet

### For Wired Connection:
Should work automatically. Test it:
```bash
ping -c 3 1.1.1.1
```

### For WiFi:
```bash
sudo systemctl start wpa_supplicant
nmtui
```
Then select "Activate a connection" and connect to your network.

---

## Step 3: Partition Your Disk

**WARNING: This will ERASE everything on the disk!**

Replace `/dev/sda` with your actual disk (use `lsblk` to find it):

```bash
# Check your disks first!
lsblk

# Set your disk (CHANGE THIS if needed!)
DISK=/dev/sda

# Partition the disk (GPT + UEFI)
sudo parted --script "$DISK" mklabel gpt
sudo parted --script "$DISK" mkpart primary 1MiB 513MiB
sudo parted --script "$DISK" set 1 boot on
sudo parted --script "$DISK" mkpart primary 513MiB 100%

# Format partitions
sudo mkfs.fat -F32 ${DISK}1
sudo mkfs.ext4 -L nixos-root ${DISK}2

# Mount everything
sudo mount ${DISK}2 /mnt
sudo mkdir -p /mnt/boot
sudo mount ${DISK}1 /mnt/boot
```

---

## Step 4: Choose Installation Method

You have two options: install directly from GitHub (faster, simpler) or clone the repo (allows customization).

### Option A: Install Directly from GitHub (Recommended for first-time)

Skip to Step 5. You'll use this command in Step 7 instead:

```bash
sudo nixos-install --root /mnt --flake github:ultus-net/nixos-base#tower
```

**Pros:** Faster, no manual cloning needed
**Cons:** Can't customize config before install

### Option B: Clone and Customize (If you want to edit configs first)

```bash
cd /mnt
sudo git clone https://github.com/ultus-net/nixos-base.git
cd nixos-base
```

Then use this command in Step 7:

```bash
sudo nixos-install --root /mnt --flake /mnt/nixos-base#tower
```

**Pros:** Can edit configs before install
**Cons:** Takes slightly longer

---

## Step 5: Generate Hardware Configuration

```bash
sudo nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix`. We need to copy it:

```bash
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/nixos-base/machines/hardware-configuration.nix
```

---

## Step 5.5: IMPORTANT - Prevent "No Space Left" Errors

**The live ISO can run out of space during installation!** The COSMIC desktop with gaming packages is large (~40-50GB). Fix this before installing:

### Option 1: Use a Larger ISO or Add Swap (Recommended)

Create a swap file on your target disk to give the installer more memory:

```bash
# Create 16GB swap file (adjust size based on your RAM)
sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# Verify swap is active
free -h
```

### Option 2: Use Minimal ISO + Binary Cache

Make sure you're using the **minimal ISO** (not the graphical one) which uses less RAM. The installer will download pre-built binaries instead of building from source.

### Option 3: Install in Stages (If still running out of space)

Install without gaming packages first, then add them after:

1. **First:** Comment out gaming packages temporarily in your fork
2. **Install:** Run the basic installation
3. **After boot:** Enable gaming and rebuild

### Verify Available Space

Before installing, check:
```bash
free -h          # Check RAM and swap
df -h            # Check disk space
```

You should have at least:
- 8GB free RAM + swap combined
- 50GB free disk space on `/mnt`

---

## Step 6: Copy Hardware Configuration

### If you chose Option A (GitHub install):

The hardware config needs to be added after first boot. For now, the install will use the repo's default. You'll customize it later if needed.

### If you chose Option B (Cloned repo):

Copy the generated hardware config:

```bash
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/nixos-base/machines/hardware-configuration.nix
```

You can also verify the tower.nix configuration:

```bash
cat /mnt/nixos-base/machines/tower.nix
```

---

## Step 7: Install NixOS

Now run the installer. This will take a while (30+ minutes depending on your connection):

### If you chose Option A (GitHub install):

```bash
sudo nixos-install --root /mnt --flake github:ultus-net/nixos-base#tower
```

### If you chose Option B (Cloned repo):

```bash
sudo nixos-install --root /mnt --flake /mnt/nixos-base#tower
```

**Notes:**
- You'll see lots of packages being downloaded and built
- The Steam package has a custom patch applied (that's normal)
- Near the end, it will ask you to set a root password - **SET ONE!**
- If you see "experimental Nix feature" warnings, ignore them or add the flags shown in the Troubleshooting section

---

## Step 8: Reboot

```bash
sudo reboot
```

Remove the USB drive when prompted.

---

## Step 9: First Boot Setup

After the system boots into COSMIC:

### A. Log in as root
Use the root password you set during installation.

### B. Set the user password
```bash
passwd hunter
```

### C. Test the user account
```bash
su - hunter
```

### D. (Optional) Add your SSH key
If you want SSH access, edit the config:
```bash
sudo nano /etc/nixos/machines/tower.nix
```

Find this section:
```nix
openssh.authorizedKeys.keys = [
  # Add your SSH public keys here
];
```

Add your key inside the brackets:
```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC... your-key-here"
];
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower
```

---

## Step 10: Set Up Config Management

### If you installed from GitHub (Option A):

Clone the repo to your system so you can make changes:

```bash
cd /home/hunter
git clone https://github.com/ultus-net/nixos-base.git
sudo ln -s /home/hunter/nixos-base /etc/nixos
```

Now you can rebuild with:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower
```

### If you cloned before install (Option B):

Move the config to a standard location:

```bash
sudo mv /mnt/nixos-base /etc/nixos
```

Now you can rebuild with:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower
```

---

## Troubleshooting

### "sudo: cannot run" or "command not found" errors

**If you accidentally broke your live ISO with incorrect bind mount commands, you need to reboot!**

The system cannot be recovered once `/nix` is hidden. Simply:
1. Reboot the live ISO (remove and reinsert USB if needed)
2. Start over from Step 1
3. Follow the corrected swap instructions in Step 5.5

### "No space left on device" during installation

**This is the #1 issue with large installations!** The live ISO uses RAM for downloads, which fills up quickly.

**Solutions:**

1. **Add swap space** (do this BEFORE installing):
```bash
sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile
free -h  # Verify swap is active
```

2. **Use the minimal ISO** (not the graphical one) - downloads less to RAM

3. **Install in stages**:
   - Fork the repo and temporarily disable gaming packages
   - Install the base system
   - After first boot, enable gaming and rebuild

If installation already failed, you need to **reboot the live ISO** (the system is broken after the bind mount). Then follow the steps above.

### "some substitutes failed" or "Cannot build" errors

Usually caused by running out of space. See solution above. You can also:
```bash
# Check what's using space
du -sh /nix/store
df -h /nix

# Clean up if needed
sudo nix-collect-garbage -d
```

### "experimental Nix feature 'nix-command' is disabled"
The flake already enables this, but if you see this during install, use:
```bash
sudo nix --extra-experimental-features 'nix-command flakes' nixos-install --root /mnt --flake /mnt/nixos-base#tower
```

### Can't boot / black screen
1. Reboot into the live ISO
2. Mount your partitions again (Step 3, just the mount commands)
3. Check `/mnt/boot` has files in it
4. Reinstall the bootloader:
```bash
sudo nixos-enter --root /mnt
nixos-rebuild boot --flake /etc/nixos#tower
exit
sudo reboot
```

### Steam won't launch
Steam has a custom patch applied. If it still fails:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower --show-trace
```

Check the build output for errors.

### WiFi not working after install
```bash
sudo systemctl enable --now NetworkManager
```

---

## Quick Command Cheat Sheet

After installation, these are your most used commands:

```bash
# Update the system
sudo nixos-rebuild switch --flake /etc/nixos#tower

# Update flake inputs (get latest packages)
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#tower

# Search for packages
nix search nixpkgs <package-name>

# Install a temporary package (doesn't persist after reboot)
nix-shell -p <package-name>

# List all generations (for rollback)
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Clean old generations (free up space)
sudo nix-collect-garbage -d
```

---

## What's Included

### Desktop
- COSMIC Desktop Environment
- Firefox, Thunderbird
- Alacritty terminal
- VS Code (enabled in home-manager)

### Gaming
- Steam (with Proton)
- Lutris
- Heroic Games Launcher
- MangoHud (performance overlay)
- Gamemode

### Multimedia
- OBS Studio
- Kdenlive (video editor)
- Audacity (audio editor)
- GIMP (image editor)
- VLC, MPV

### Development
- Git, VS Code
- Docker, Podman
- VirtualBox, virt-manager

### System Tools
- htop, btop (system monitors)
- gparted (partition editor)
- Various hardware utilities

---

## Post-Install: Customize Your System

1. **Change username**: Edit `/etc/nixos/machines/tower.nix` and change all instances of "hunter"
2. **Add packages**: Add to `environment.systemPackages` in tower.nix
3. **Switch desktops**: Change `../profiles/cosmic.nix` to gnome/kde/xfce/etc.
4. **Disable features**: Set `gaming.enable = false;` (or multimedia, virtualization, etc.)

After any changes:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower
```

---

## Need Help?

- Check `INSTALL.md` for detailed documentation
- Check `TROUBLESHOOTING.md` for common issues
- Check `USAGE.md` for day-to-day usage tips
- Check the NixOS manual: https://nixos.org/manual/nixos/stable/

---

**That's it! Enjoy your new COSMIC NixOS system!** 🚀
