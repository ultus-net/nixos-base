# NixOS Base Configuration

A minimal, modular, and desktop environment agnostic NixOS configuration. This repository provides a solid foundation for building your own NixOS system without being tied to any specific desktop environment.

## Features

- **Desktop Environment Agnostic**: No DE/WM pre-installed, allowing you to choose your preferred environment
- **Modular Configuration**: Separated concerns (boot, networking, users, packages, services)
- **Flakes-based**: Modern NixOS configuration using flakes
- **Home Manager Ready**: Optional integration with home-manager for user-specific configurations
- **Well-documented**: Clear configuration with comments explaining each section

## Structure

```
.
├── flake.nix                          # Flake configuration entry point
├── configuration.nix                   # Main system configuration
├── hardware-configuration.nix.template # Hardware config template
├── home.nix.template                  # Home Manager config template
└── modules/
    ├── boot.nix                       # Boot loader and kernel configuration
    ├── networking.nix                 # Network settings and firewall
    ├── users.nix                      # User account management
    ├── packages.nix                   # System-wide packages
    └── services.nix                   # System services
```

## Quick Start

### Prerequisites

- A machine with NixOS installed or a NixOS ISO for installation
- Basic familiarity with NixOS concepts

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/ultus-net/nixos-base.git
   cd nixos-base
   ```

2. **Generate your hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. **Customize the configuration:**
   - Edit `configuration.nix` to set your timezone, locale, etc.
   - Edit `modules/users.nix` to configure your user account
   - Edit `modules/networking.nix` to set your hostname
   - Review and adjust other modules as needed

4. **Update flake.nix:**
   - Change the hostname in `nixosConfigurations` from "nixos-base" to your desired hostname

5. **Build and activate:**
   ```bash
   # Test the configuration
   sudo nixos-rebuild test --flake .#nixos-base
   
   # If everything works, switch to the new configuration
   sudo nixos-rebuild switch --flake .#nixos-base
   ```

## Configuration Modules

### Boot Configuration (`modules/boot.nix`)
- Systemd-boot (UEFI) configured by default
- GRUB configuration commented for easy switching
- Support for additional filesystems (NTFS, exFAT)

### Networking (`modules/networking.nix`)
- NetworkManager enabled for easy network management
- Basic firewall configuration
- IPv6 support

### Users (`modules/users.nix`)
- Default user "nixos" with common groups
- Easily customizable for multiple users
- Sudo access for wheel group

### Packages (`modules/packages.nix`)
- Essential CLI tools (vim, git, htop, etc.)
- Network utilities
- File management tools
- Build tools
- No GUI applications - keep it minimal!

### Services (`modules/services.nix`)
- OpenSSH enabled with secure defaults
- PipeWire for modern audio support
- Optional services commented (Docker, printing, etc.)

## Adding a Desktop Environment

This base configuration intentionally excludes desktop environments. To add one:

### GNOME Example:
```nix
# Add to configuration.nix or create modules/desktop.nix
services.xserver = {
  enable = true;
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
};
```

### KDE Plasma Example:
```nix
services.xserver = {
  enable = true;
  displayManager.sddm.enable = true;
  desktopManager.plasma6.enable = true; # Use plasma5 for NixOS <24.11
};
```

### Window Manager (i3) Example:
```nix
services.xserver = {
  enable = true;
  windowManager.i3.enable = true;
  displayManager.lightdm.enable = true;
};
```

## Using Home Manager

Home Manager is commented out in `flake.nix` by default. To enable it:

1. **Uncomment the Home Manager section in `flake.nix`**

2. **Create your home configuration:**
   ```bash
   cp home.nix.template home.nix
   # Edit home.nix with your preferences
   ```

3. **Rebuild your system:**
   ```bash
   sudo nixos-rebuild switch --flake .#nixos-base
   ```

## Customization Tips

- **System Timezone**: Edit `time.timeZone` in `configuration.nix`
- **Locale**: Adjust `i18n.defaultLocale` and related settings in `configuration.nix`
- **Hostname**: Change in `modules/networking.nix`
- **User Accounts**: Modify `modules/users.nix`
- **Add Packages**: Update `modules/packages.nix` for system-wide or `home.nix` for user-specific packages
- **Enable Services**: Uncomment desired services in `modules/services.nix`

## Maintenance

### Update the system:
```bash
# Update flake inputs
nix flake update

# Rebuild with updated packages
sudo nixos-rebuild switch --flake .#nixos-base
```

### Clean up old generations:
```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Garbage collect
sudo nix-collect-garbage -d
```

## Contributing

Contributions are welcome! Please ensure any changes maintain the desktop environment agnostic nature of this configuration.

## License

This configuration is provided as-is for anyone to use and modify.

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)