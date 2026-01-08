# Scripts

Helper scripts for managing your NixOS system.

## Available Scripts

### `switch-desktop.sh`
Switch between desktop environments without manual configuration editing.

**Usage:**
```bash
./scripts/switch-desktop.sh <desktop-name>
```

**Example:**
```bash
# Switch from GNOME to KDE
./scripts/switch-desktop.sh kde

# Switch to COSMIC
./scripts/switch-desktop.sh cosmic
```

**Available desktops:** cosmic, gnome, kde, cinnamon, xfce, mate, budgie, pantheon, lxqt

### `switch-host.sh`
Switch the hostname of your system.

**Usage:**
```bash
./scripts/switch-host.sh <new-hostname>
```

### `collect-system-info.sh`
Gather system information for troubleshooting.

**Usage:**
```bash
./scripts/collect-system-info.sh
```

This collects:
- Hardware configuration
- NixOS version
- Installed packages
- Active desktop environment
- System logs

### `validate-hosts-home-manager.sh`
Validate Home Manager configurations.

**Usage:**
```bash
./scripts/validate-hosts-home-manager.sh
```

### `partition-drive.sh`
Automatically partition a drive for NixOS installation. This script handles all partitioning automatically - you just specify which drive to use.

**Usage:**
```bash
sudo ./scripts/partition-drive.sh <device>
```

**Examples:**
```bash
# Partition /dev/sda for NixOS
sudo ./scripts/partition-drive.sh /dev/sda

# Partition an NVMe drive
sudo ./scripts/partition-drive.sh /dev/nvme0n1
```

**⚠️ WARNING:** This script will **DESTROY ALL DATA** on the target device!

**What it does automatically:**
1. Detects firmware type (UEFI or BIOS)
2. Wipes the target device
3. Creates partition table (GPT for UEFI, MBR for BIOS)
4. Creates boot partition (512M)
5. Creates swap partition (8G)
6. Creates root partition (remaining space)
7. Formats all partitions with appropriate filesystems
8. Mounts partitions at /mnt ready for installation

After running this script, you're ready to install:
```bash
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix
nixos-install
```

## Tips

- Make scripts executable: `chmod +x scripts/*.sh`
- Run from repository root for best results
- Most scripts require sudo/root privileges
- Check script comments for detailed usage information
