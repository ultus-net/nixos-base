# Boot Failure Fix - January 12, 2026

## Problem
The most recent commit (7088b8e) added aggressive performance optimizations that caused the system to fail to boot.

## Root Causes Identified

### 1. **Filesystem Options Override**
The configuration tried to completely override filesystem options for `/` and `/boot`:

```nix
fileSystems."/" = {
  options = [ "noatime" "nodiratime" "discard=async" "commit=60" ];
};

fileSystems."/boot" = {
  options = [ "noatime" "discard=async" ];
};
```

**Problem**: This replaced the essential FAT filesystem options (`fmask=0077` and `dmask=0077`) that were defined in `hardware-configuration.nix` for the `/boot` partition. Without these options, the UEFI boot partition cannot be properly mounted, causing boot failure.

### 2. **Incompatible Kernel Parameters**
Several kernel parameters were added that may not be supported or could cause instability:

- `processor.max_cstate=1` - Restricts CPU power states, can cause crashes on some systems
- `tsc=reliable` + `clocksource=tsc` - Assumes TSC is stable, but this can cause timing issues if incorrect
- `ntsync.enable=1` - This feature may not be available in the current kernel version

### 3. **Unsupported I/O Scheduler**
The configuration tried to force the `kyber` I/O scheduler:

```nix
ATTR{queue/scheduler}="kyber"
```

**Problem**: The kyber scheduler may not be compiled into the kernel, causing udev rules to fail and potentially preventing disk initialization.

## Fixes Applied

### 1. **Fixed Filesystem Options**
Changed from complete override to proper merging:

```nix
# Merge options instead of replacing them
fileSystems."/".options = [ "noatime" "nodiratime" "discard=async" "commit=60" ];

# Use lib.mkAfter to append to existing boot options (preserves fmask/dmask)
fileSystems."/boot".options = lib.mkAfter [ "noatime" ];
```

### 2. **Removed Problematic Kernel Parameters**
Kept only safe, well-tested parameters:

```nix
boot.kernelParams = [
  "mitigations=off"           # Safe performance gain
  "nowatchdog"                # Safe performance improvement
  "transparent_hugepage=always" # Widely supported
];
```

**Removed**:
- `processor.max_cstate=1` - Can cause instability
- `tsc=reliable` and `clocksource=tsc` - Hardware-specific, risky
- `ntsync.enable=1` - Not available in current kernel

### 3. **Safer I/O Scheduler Configuration**
Changed to use `none` scheduler (which is always available):

```nix
# Use 'none' scheduler (always available) for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", TEST=="queue/scheduler", ATTR{queue/scheduler}="none"
```

The `none` scheduler is the default for NVMe drives and provides excellent performance without compatibility issues.

## Performance Impact

The fixes maintain most of the performance benefits while ensuring system stability:

**Kept**:
- ✅ zram configuration (8GB)
- ✅ CPU governor set to "performance"
- ✅ TCP BBR congestion control
- ✅ Optimized sysctl settings
- ✅ SSD optimizations (noatime, discard)
- ✅ tmpfs for /tmp
- ✅ Journal size limits
- ✅ Safe kernel optimizations

**Removed** (for stability):
- ❌ Aggressive C-state restrictions
- ❌ TSC clocksource forcing
- ❌ ntsync feature (not available)
- ❌ kyber I/O scheduler (compatibility)

## Testing

To test the fixed configuration:

```bash
cd /home/hunter/Documents/nixos-base
sudo nixos-rebuild test
```

If successful, apply permanently:

```bash
sudo nixos-rebuild switch
```

## Lessons Learned

1. **Never override FAT filesystem options** - The boot partition requires specific fmask/dmask settings
2. **Use `lib.mkAfter` or `lib.mkMerge`** when modifying filesystem options to preserve hardware-configuration.nix settings
3. **Test kernel parameters incrementally** - Add one at a time to identify which ones cause issues
4. **Check kernel feature availability** - Not all features (like ntsync) are available in all kernel versions
5. **Default schedulers are optimized** - The Linux kernel already uses good defaults for NVMe (none/mq-deadline)

## References

- NixOS Manual: [File Systems](https://nixos.org/manual/nixos/stable/#sec-file-systems)
- NixOS Manual: [Options Merging](https://nixos.org/manual/nixos/stable/#sec-option-types)
- Linux Kernel: [Block I/O Schedulers](https://www.kernel.org/doc/html/latest/block/index.html)
