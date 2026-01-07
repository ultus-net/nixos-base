# Troubleshooting Guide

Common issues and solutions when using nixos-base.

## Installation Issues

### "No space left on device" during installation

**Problem:** The `/boot` partition is too small or full.

**Solution:**
```bash
# Check boot partition usage
df -h /boot

# If full, clean old generations before installing
nix-collect-garbage -d
```

### "Permission denied" when running nixos-install

**Problem:** Not running as root.

**Solution:**
```bash
sudo nixos-install --flake /mnt/nixos-base#<desktop>-workstation
```

### Flake evaluation fails with "does not provide attribute"

**Problem:** Typo in desktop name or missing profile.

**Solution:**
```bash
# List available configurations
nix flake show /mnt/nixos-base

# Common typo: missing "-workstation" suffix
nixos-install --flake /mnt/nixos-base#cosmic-workstation  # Correct
nixos-install --flake /mnt/nixos-base#cosmic              # Wrong
```

## Desktop Environment Issues

### COSMIC: "No display found" or black screen

**Problem:** COSMIC requires Wayland and proper GPU drivers.

**Solution:**
1. Ensure your GPU is supported
2. Check if running on NVIDIA (requires additional setup)
3. Try forcing enabled output in your machine config:
   ```nix
   hardware.display.outputs."DP-1".mode = "e";
   ```

### GNOME: Extensions not loading

**Problem:** GNOME extensions need to be enabled per-user.

**Solution:**
```bash
# Install GNOME Extensions app
nix-shell -p gnome-extensions-cli

# Enable an extension
gnome-extensions enable <extension-uuid>
```

### KDE Plasma: Wayland session not available

**Problem:** Wayland not enabled or missing dependencies.

**Solution:**
In your machine config:
```nix
kde.enableWayland = true;
```

### Display manager doesn't start after installation

**Problem:** Missing or misconfigured display manager.

**Solution:**
1. Check logs: `journalctl -xeu display-manager.service`
2. Verify X11/Wayland service is running
3. Try switching to TTY (Ctrl+Alt+F2) and rebuild:
   ```bash
   sudo nixos-rebuild switch
   ```

## Network Issues

### No internet connection after boot

**Problem:** Network manager not enabled or not started.

**Solution:**
The base configuration enables NetworkManager by default, but check:
```bash
# Check NetworkManager status
systemctl status NetworkManager

# If not running, start it
sudo systemctl start NetworkManager

# Connect to WiFi
nmtui
```

### SSH connection refused

**Problem:** SSH not enabled or firewall blocking.

**Solution:**
In `machines/configuration.nix`, SSH is enabled by default but verify:
```nix
services.openssh.enable = true;
networking.firewall.allowedTCPPorts = [ 22 ];
```

## Build/Update Issues

### "hash mismatch" when updating

**Problem:** Cached hash doesn't match actual download.

**Solution:**
```bash
# Clear nix store cache
nix-store --verify --check-contents --repair

# Or re-fetch with updated hash
nix flake lock --update-input nixpkgs
```

### "out of memory" during build

**Problem:** Not enough RAM for build.

**Solution:**
```bash
# Limit parallel builds
nixos-rebuild switch --option max-jobs 1 --option cores 2

# Or add swap space temporarily
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Rebuild takes forever on slow connection

**Problem:** Downloading many packages from cache.

**Solution:**
```bash
# Use a mirror
nix-channel --add https://nixos.org/channels/nixos-unstable nixos

# Or build without substitutes (will compile locally)
nixos-rebuild switch --option substitute false
```

## Home Manager Issues

### "Collision between..." package conflicts

**Problem:** Same package installed both system-wide and via Home Manager.

**Solution:**
Remove duplicate from either:
- `environment.systemPackages` in your machine config, OR
- `home.packages` in your Home Manager config

### Home Manager service fails to start

**Problem:** Syntax error or missing imports.

**Solution:**
```bash
# Check home-manager logs
journalctl --user -xeu home-manager-<username>.service

# Validate configuration
home-manager build
```

## Recovery Options

### System won't boot after update

**Solution:**
1. At GRUB menu, select previous generation
2. Once booted:
   ```bash
   # List generations
   nix-env --list-generations --profile /nix/var/nix/profiles/system
   
   # Rollback to previous
   sudo nixos-rebuild --rollback switch
   ```

### Can't login after user configuration change

**Solution:**
1. Boot into recovery mode (select from GRUB)
2. Or use TTY (Ctrl+Alt+F2)
3. Check user configuration:
   ```bash
   sudo cat /etc/passwd | grep <username>
   ```

### Complete system rescue

**Solution:**
1. Boot from NixOS live ISO
2. Mount your system:
   ```bash
   mount /dev/sdaX /mnt
   mount /dev/sdaY /mnt/boot
   ```
3. Fix configuration and reinstall:
   ```bash
   nixos-install --root /mnt --flake /mnt/nixos-base#<desktop>-workstation
   ```

## Getting More Help

1. Check NixOS manual: https://nixos.org/manual/nixos/stable/
2. Search NixOS Discourse: https://discourse.nixos.org/
3. NixOS Wiki: https://nixos.wiki/
4. Open an issue: https://github.com/ultus-net/nixos-base/issues

## Debugging Commands

```bash
# Check system configuration
nixos-option system.stateVersion

# List all available options
nixos-option -r services

# Show what would be built/downloaded
nixos-rebuild dry-build

# Test configuration without making it default
sudo nixos-rebuild test

# Validate flake without building
nix flake check

# Show flake info
nix flake metadata
nix flake show
```
