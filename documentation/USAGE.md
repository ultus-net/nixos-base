# Usage Guide

## 🚀 TL;DR

```bash
# Switch desktops (already installed system)
sudo nixos-rebuild switch --flake .#kde-workstation

# Update packages
nix flake update && sudo nixos-rebuild switch --flake .#your-config

# Test in VM before deploying
nix build .#nixosConfigurations.cosmic-workstation.config.system.build.vm
./result/bin/run-*-vm

# Create custom machine config (advanced)
cp machines/example-machine.nix machines/my-machine.nix
# Edit my-machine.nix, then reference it in flake.nix
```

## Quick Start

### For New Installations

1. Boot the NixOS live ISO
2. Partition and mount your disk to `/mnt`
3. Clone this repository:
   ```bash
   cd /mnt
   git clone https://github.com/ultus-net/nixos-base
   ```
4. Generate hardware configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
5. Install with your chosen desktop:
   ```bash
   nixos-install --flake /mnt/nixos-base#gnome-workstation
   ```

See `INSTALL.md` for detailed installation instructions.

## Switching Desktops

After installation, you can switch between desktop environments:

### Switch to COSMIC
```bash
sudo nixos-rebuild switch --flake .#cosmic-workstation
```

### Switch to GNOME
```bash
sudo nixos-rebuild switch --flake .#gnome-workstation
```

### Switch to KDE
```bash
sudo nixos-rebuild switch --flake .#kde-workstation
```

### Test Without Switching
```bash
# Build without activating
nixos-rebuild build --flake .#kde-workstation

# Or using nix directly
nix build .#nixosConfigurations.kde-workstation.config.system.build.toplevel
```

## Helper Scripts

### Switch Host Script
Use the provided script to build or switch configurations:

```bash
# Build the default (cosmic) configuration
./scripts/switch-host.sh

# Switch to GNOME (requires root)
sudo ./scripts/switch-host.sh .#gnome-workstation

# Switch to KDE (requires root)
sudo ./scripts/switch-host.sh .#kde-workstation
```

### Desktop Switcher
```bash
# Interactive desktop environment switcher
./scripts/switch-desktop.sh
```

### Validation
```bash
# Validate configurations before deploying
./scripts/validate-hosts-home-manager.sh
```

See `scripts/README.md` for complete script documentation.

## Creating Your Own Machine Configuration

**When do you need this?** 
- You want to customize beyond what profiles offer
- You're setting up multiple machines with different hardware
- You want machine-specific settings (hostname, users, hardware config)

**Don't need this if:**
- You just want to use a pre-built desktop (use profiles directly)
- You're testing different desktops (just switch between profiles)

### Steps:

1. Copy the example machine template:
   ```bash
   cp machines/example-machine.nix machines/my-machine.nix
   ```

2. Edit `machines/my-machine.nix`:
   ```nix
   { config, pkgs, lib, inputs, ... }:
   {
     imports = [
       ./configuration.nix           # Base machine config
       ./hardware-configuration.nix  # Your hardware config
       ../profiles/gnome.nix         # Choose your desktop
     ];

     # Set your hostname
     networking.hostName = "my-machine";

     # Add your user
     machines.users = {
       yourname = {
         enable = true;
         isAdmin = true;
         shell = pkgs.bash;
       };
     };
   }
   ```

3. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     # ... existing configs ...
     my-machine = mkSystem ./machines/my-machine.nix;
   };
   ```

4. Build and switch:
   ```bash
   sudo nixos-rebuild switch --flake .#my-machine
   ```

See `machines/README.md` for detailed machine configuration guide.

## Enabling Optional Modules

### Add Multimedia Support
```nix
imports = [
  ../modules/multimedia.nix
];

multimedia.enable = true;
```

### Add Gaming Support
```nix
imports = [
  ../modules/gaming.nix
];

gaming.enable = true;
gaming.steam = true;
gaming.lutris = true;
```

### Add Development Tools
```nix
imports = [
  ../modules/development.nix
];

development.enable = true;
```

### Laptop Configuration
```nix
imports = [
  ../modules/laptop.nix
];

laptop.enable = true;
laptop.touchpad.enable = true;
```

See `FEATURES.md` for all available modules.

## Testing in a VM

Build and run a VM to test configurations before deploying:

```bash
# Build VM
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm

# Run VM
./result/bin/run-*-vm
```

## Updating Your System

### Update Flake Inputs
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Rebuild After Update
```bash
sudo nixos-rebuild switch --flake .#your-config
```

## Rolling Back

If something goes wrong, you can rollback to a previous generation:

```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Switch to specific generation
sudo nix-env --switch-generation <number> --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Local Testing

Before pushing changes, test locally:

```bash
# Quick validation
nix flake check

# Build specific configuration
nix build .#nixosConfigurations.gnome-workstation.config.system.build.toplevel

# Test VM boot
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm
./result/bin/run-*-vm
```

## Troubleshooting

If you encounter issues:

1. Check `TROUBLESHOOTING.md` for common problems and solutions
2. Review logs: `journalctl -xe`
3. Verify configuration: `nixos-rebuild dry-run --flake .#your-config`
4. Ask for help in the NixOS community channels

## Next Steps

- Read `FEATURES.md` to explore available modules
- Check `CONTRIBUTING.md` to add your own customizations
- Review `SECRETS.md` for secrets management
- Explore `modules/README.md` for module documentation
