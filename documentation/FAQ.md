# Frequently Asked Questions (FAQ)

## Installation & Setup

### Q: Which desktop environment should I choose?

**For beginners:**
- **GNOME** - Most polished, works out of the box
- **Cinnamon** - Familiar Windows-like interface
- **XFCE** - Lightweight and stable

**For advanced users:**
- **COSMIC** - Cutting-edge, modern Wayland desktop (may have bugs)
- **KDE** - Highly customizable, feature-rich

**For older hardware:**
- **MATE** or **LXQt** - Very lightweight

See the desktop comparison table in [README.md](../README.md) for details.

### Q: Can I dual boot with Windows?

Yes! Install Windows first, then install NixOS. The bootloader will automatically detect Windows. Make sure to:
1. Shrink your Windows partition using Windows Disk Management
2. Create separate partitions for NixOS during installation
3. Install NixOS normally - systemd-boot or GRUB will detect Windows

### Q: Why can't I log in after installation?

**Most common issue:** You forgot to set a password! This flake uses empty passwords by default for security.

**Solution:**
1. Boot into recovery mode or use a live USB
2. Mount your root partition
3. Use `nixos-enter` to chroot
4. Run `passwd username` to set a password
5. Reboot and log in

Alternatively, add SSH keys to your user config before installation.

### Q: How do I customize the default "hunter" username?

The "hunter" username is just an example. To use your own:

1. Copy `home/hunter.nix` to `home/yourusername.nix`
2. Edit `machines/example-machine.nix` (or your machine config):
   - Change `machines.users.hunter` to `machines.users.yourusername`
   - Change `home-manager.users.hunter` to `home-manager.users.yourusername`
3. Update the import: `home-manager.users.yourusername = import ../home/yourusername.nix;`
4. Rebuild: `sudo nixos-rebuild switch --flake .#your-config`

### Q: Do I need to create a machine config for my first install?

**No!** For your first installation, use the pre-built profiles directly:
```bash
nixos-install --flake /mnt/nixos-base#gnome-workstation
```

Create custom machine configs later when you want to:
- Set a custom hostname
- Add your specific hardware configuration
- Customize user accounts
- Enable/disable specific modules

## System Management

### Q: How do I update my system?

```bash
# Update flake inputs (gets latest package versions)
nix flake update

# Rebuild with new packages
sudo nixos-rebuild switch --flake .#your-config

# Or in one command
nix flake update && sudo nixos-rebuild switch --flake .#your-config
```

### Q: How do I switch desktop environments?

```bash
# Switch to a different desktop
sudo nixos-rebuild switch --flake .#kde-workstation

# Or use the helper script
./scripts/switch-desktop.sh kde
```

Then log out and select the new desktop from your display manager.

### Q: Can I have multiple desktop environments installed?

Yes, but it's not recommended. Desktop environments can conflict with each other. Instead:
- Use VMs to test different desktops
- Switch between profiles and reboot
- Set up multiple user accounts with different desktops

### Q: How do I add more users?

Edit your machine configuration:

```nix
machines.users = {
  firstuser = {
    isNormalUser = true;
    description = "First User";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  seconduser = {
    isNormalUser = true;
    description = "Second User";
    extraGroups = [ "networkmanager" ];  # No wheel = no sudo
  };
};
```

Then rebuild: `sudo nixos-rebuild switch --flake .#your-config`

### Q: How do I rollback to a previous generation?

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Switch to a specific generation
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Optional Modules

### Q: How do I enable gaming support?

Add to your machine configuration:

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/gaming.nix
  ];
  
  gaming.enable = true;
}
```

Then rebuild. This installs Steam, Lutris, MangoHUD, and gaming optimizations.

### Q: How do I enable laptop-specific features?

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/laptop.nix
  ];
  
  laptop.enable = true;
}
```

This enables TLP (power management), touchpad configuration, and battery optimization.

### Q: Can I install Flatpak apps?

The flakes don't include Flatpak by default, but you can add it:

```nix
services.flatpak.enable = true;
```

Then install apps:
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.mozilla.firefox
```

## Troubleshooting

### Q: I get "experimental feature 'nix-command' is disabled"

This configuration enables flakes by default, but if you see this error:

**Temporary fix:**
```bash
nix --extra-experimental-features 'nix-command flakes' <your-command>
```

**Permanent fix:** Ensure `machines/configuration.nix` has:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Q: My build fails with "evaluation error"

Common causes:
1. Syntax error in your Nix files - check with `nix flake check`
2. Missing import - ensure all `imports = [ ... ]` paths are correct
3. Conflicting options - check for duplicate module imports
4. Outdated flake.lock - try `nix flake update`

Run `nix flake check` for detailed error messages.

### Q: WiFi doesn't work after installation

1. Check NetworkManager is running: `systemctl status NetworkManager`
2. Use text UI to connect: `nmtui`
3. Or use command line: `nmcli device wifi connect "SSID" password "PASSWORD"`

If NetworkManager isn't running, add to your config:
```nix
networking.networkmanager.enable = true;
```

### Q: How do I uninstall/remove NixOS?

NixOS doesn't have an uninstaller. To remove:
1. Boot from another OS (live USB, other Linux, Windows)
2. Delete NixOS partitions using `fdisk`, `parted`, or Windows Disk Management
3. Recreate partitions for another OS
4. Install the new OS

**Warning:** This will delete all data on NixOS partitions!

## Advanced

### Q: Can I use this on non-NixOS systems?

The Home Manager configurations can be used standalone on any Linux/macOS:

```bash
# Install Home Manager
nix run home-manager/master -- init --switch

# Use this flake's config
home-manager switch --flake .#hunter@x86_64-linux
```

See [home/README.md](../home/README.md) for details.

### Q: How do I contribute a new desktop environment?

See [CONTRIBUTING.md](CONTRIBUTING.md) for complete guidelines. The basic steps:
1. Create `modules/yourdesktop.nix`
2. Create `profiles/yourdesktop.nix`
3. Add to `flake.nix` nixosConfigurations
4. Update documentation
5. Submit a pull request

### Q: Can I use this in production/servers?

Yes! Use the `base-server` profile for headless systems:
```bash
nixos-install --flake /mnt/nixos-base#base-server
```

Then customize by creating a machine config and importing only the modules you need.

### Q: Where are the wallpapers stored?

Official NixOS wallpapers are in `/run/current-system/sw/share/backgrounds/nixos/`. 

The wallpaper module (enabled by default) automatically rotates through them. To customize:
```nix
wallpapers = {
  enable = true;
  rotationInterval = "1h";  # Change rotation time
};
```

Or disable: `wallpapers.enable = false;`

## Still Have Questions?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [ARCHITECTURE.md](ARCHITECTURE.md) to understand the structure
- Open an issue on GitHub
- Ask in NixOS community channels (Discourse, Matrix, Reddit)
