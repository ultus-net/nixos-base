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

## Tips

- Make scripts executable: `chmod +x scripts/*.sh`
- Run from repository root for best results
- Most scripts require sudo/root privileges
- Check script comments for detailed usage information
