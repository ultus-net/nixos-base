# Quick Install Guide - COSMIC Workstation (tower.nix)

This is a copy-paste friendly guide for installing NixOS with the COSMIC desktop
using the tower.nix configuration.

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

## Step 4: Clone the Repository

```bash
cd /mnt
sudo git clone https://github.com/ultus-net/nixos-base.git
cd nixos-base
```

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

## Step 6: Verify tower.nix Configuration

The tower.nix file should already be configured, but let's check it exists:

```bash
cat /mnt/nixos-base/machines/tower.nix
```

You should see the tower configuration. It's already set up!

---

## Step 7: Install NixOS

Now run the installer. This will take a while (30+ minutes depending on your connection):

```bash
sudo nixos-install --root /mnt --flake /mnt/nixos-base#tower
```

**Notes:**
- You'll see lots of packages being downloaded and built
- The Steam package has a custom patch applied (that's normal)
- Near the end, it will ask you to set a root password - **SET ONE!**

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

## Step 10: Update the Config Path (Optional but Recommended)

The system is installed, but the config is in `/mnt/nixos-base`. Let's move it:

```bash
sudo mv /mnt/nixos-base /etc/nixos
```

Now you can rebuild with:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#tower
```

---

## Troubleshooting

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
