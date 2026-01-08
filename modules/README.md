# NixOS Modules

This directory contains modular NixOS configuration fragments. Each module is opt-in and provides specific functionality.

## Core Modules

### System Configuration
- **`boot.nix`** - Boot loader and kernel configuration
- **`networking.nix`** - Network management (NetworkManager)
- **`security.nix`** - Security hardening and SSH configuration
- **`audio.nix`** - PipeWire audio stack
- **`fonts.nix`** - Font packages (Nerd Fonts, emoji)
- **`zram.nix`** - ZRAM compressed swap
- **`wallpapers.nix`** - NixOS official wallpaper collection with automatic rotation

### Package Collections
- **`common-packages.nix`** - Essential CLI tools and modern replacements (htop, btop, ripgrep, fzf, eza, bat, git, etc.)
- **`development.nix`** - Development tools and language runtimes

### Optional Feature Modules
- **`gaming.nix`** - Gaming tools (Steam, Lutris, MangoHUD, etc.)
- **`virtualization.nix`** - VM support (libvirt, QEMU, virt-manager)
- **`laptop.nix`** - Laptop-specific settings (power management, TLP)
- **`multimedia.nix`** - Media tools (VLC, GIMP, ffmpeg, OBS)
- **`containers.nix`** - Container tools (Docker, distrobox, Kubernetes)
- **`sysadmin.nix`** - System administration tools (backups, network diagnostics, hardware monitoring)

### Desktop Environments
- **`cosmic.nix`** - System76 COSMIC desktop
- **`gnome.nix`** - GNOME Shell
- **`kde.nix`** - KDE Plasma 6
- **`cinnamon.nix`** - Cinnamon (Linux Mint)
- **`xfce.nix`** - XFCE
- **`mate.nix`** - MATE
- **`budgie.nix`** - Budgie
- **`pantheon.nix`** - Pantheon (elementary OS)
- **`lxqt.nix`** - LXQt

### User Configuration
- **`common-users.nix`** - User account management
- **`home-manager.nix`** - Home Manager integration

## Usage

### In a Profile

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/common-packages.nix
    ../modules/development.nix
    ../modules/multimedia.nix  # Optional
    ../modules/gaming.nix      # Optional
  ];

  # Enable modules
  commonPackages.enable = true;
  gaming.enable = true;
  multimedia.enable = true;
}
```

### In a Machine Configuration

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/laptop.nix
    ../modules/sysadmin.nix
    ../modules/containers.nix
  ];

  # Configure laptop features
  laptop = {
    enable = true;
    enableBluetooth = true;
    enableTLP = true;
  };

  # Enable sysadmin tools
  sysadmin = {
    enable = true;
    enableBackupTools = true;
    enableNetworkDiagnostics = true;
  };

  # Enable containers
  containers = {
    enable = true;
    enableDistrobox = true;
    enableDockerCompose = false;
  };
}
```

## Module Options

### multimedia.nix

```nix
multimedia = {
  enable = true;
  enableVideoEditing = true;    # Kdenlive, Blender
  enableAudioProduction = true; # Audacity, Ardour
  extraPackages = [ pkgs.handbrake ];
};
```

**Includes:**
- Media players: VLC, MPV
- Image tools: GIMP, ImageMagick, feh, imv
- Video tools: ffmpeg, yt-dlp
- Screenshot: grim, slurp, flameshot, peek
- Recording: OBS Studio

### containers.nix

```nix
containers = {
  enable = true;
  enableDistrobox = true;       # Run other distros in containers
  enableKubernetes = true;      # kubectl, k9s, helm
  enableDockerCompose = true;   # Install docker-compose
  extraPackages = [ pkgs.docker-compose ];
};
```

**Includes:**
- Docker with compose support
- Distrobox + BoxBuddy GUI
- Optional: Kubernetes tools

### sysadmin.nix

```nix
sysadmin = {
  enable = true;
  enableBackupTools = true;         # restic, rclone, borgbackup
  enableNetworkDiagnostics = true;  # bandwhich, gping, wireshark
  enableHardwareMonitoring = true;  # smartmontools, lm_sensors
  extraPackages = [ pkgs.ansible ];
};
```

**Includes:**
- Backup: restic, rclone, syncthing, borgbackup
- Network: bandwhich, gping, nmap, wireshark, iperf3
- Hardware: smartmontools, lm_sensors, nvme-cli
- Filesystems: NTFS, exFAT, ext4 tools
- Modern tools: procs, duf, dust

### gaming.nix

```nix
gaming = {
  enable = true;
  enableI386Compat = true;
  enableProtonEnv = true;
  protonEnv = {
    PROTON_ENABLE_NVAPI = "1";
    DXVK_ASYNC = "1";
  };
};
```

**Includes:**
- Steam, Lutris, Heroic
- MangoHUD, GameMode
- Proton tools
- Vulkan support

### laptop.nix

```nix
laptop = {
  enable = true;
  enableBluetooth = true;
  enableTLP = true;
  enableBacklight = true;
};
```

**Features:**
- Power management (TLP)
- Bluetooth support
- Backlight control
- Battery optimization

---

## wallpapers.nix

Installs the complete collection of official NixOS wallpapers from `nixos-artwork` and makes them available system-wide for automatic rotation by desktop environments.

**Enable:**
```nix
machines.wallpapers.enable = true;
machines.wallpapers.rotationInterval = 300;  # seconds (5 minutes)
```

**Features:**
- 40+ official NixOS wallpapers including:
  - Binary series (black, blue, red, white)
  - Catppuccin color schemes (frappe, latte, macchiato, mocha)
  - Nineish retro series with Catppuccin variants
  - Classic NixOS wallpapers (simple-blue, mosaic-blue, stripes)
  - 3D renders (gear, moonscape, recursive, waterfall)
- System-wide installation accessible to all desktop environments
- Home Manager integration for automatic wallpaper symlinks
- Rotation configured via COSMIC, GNOME, KDE, etc.

**Note:** This module is enabled by default in all desktop profiles. The Home Manager configuration ([home/hunter.nix](../home/hunter.nix)) automatically symlinks all wallpapers to `~/.wallpapers` for rotation.

---

## Creating New Modules

See `CONTRIBUTING.md` for guidelines on creating new modules.

### Module Template

```nix
{ config, pkgs, lib, ... }:
let
  cfg = config.myModule;
in {
  options.myModule = {
    enable = lib.mkEnableOption "Enable my module";
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # your packages here
    ] ++ cfg.extraPackages;
  };
}
```

## Best Practices

1. **Use `lib.mkEnableOption`** for opt-in modules
2. **Provide `extraPackages`** option for extensibility
3. **Use `lib.mkDefault`** for easily overridable values
4. **Document options** with clear descriptions
5. **Keep modules focused** - one concern per module
6. **Use `lib.mkIf`** to conditionally enable features
7. **Add comments** explaining non-obvious configurations
