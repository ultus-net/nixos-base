# Performance Tuning Guide

This guide documents the performance optimizations applied to the NixOS tower configuration, providing details on what was changed, why, and how to verify the improvements.

## Overview

The tower configuration includes comprehensive performance tuning targeting:
- **Gaming Performance**: Lower latency, higher FPS, better Wine/Proton compatibility
- **Desktop Responsiveness**: Faster application launches, smoother UI interactions
- **Boot Speed**: Reduced boot times through parallel startup and optimizations
- **Network Performance**: Improved throughput and latency
- **SSD Longevity**: Reduced wear through zram and optimized mount options

## Applied Optimizations

### 1. Memory & Swap Management

#### zram Compression Swap
**Location**: `machines/tower.nix`

```nix
machines.zram.enableAutoSize = true;
machines.zram.maxSize = 8589934592; # 8GB
machines.zram.compAlgorithm = "zstd";
```

**Benefits**:
- 3-5x compression ratio reduces actual RAM pressure
- Eliminates disk I/O for most swap operations
- Extends SSD lifespan by reducing writes
- Faster swap operations (RAM speed vs disk speed)

**Verification**:
```bash
zramctl  # Should show active zram device
swapon --show  # Check priority (zram should be higher)
```

#### Reduced Swapfile Size
Swapfile reduced from 32GB to 16GB since zram handles primary swapping.

**Considerations**: If you need hibernation, consider keeping swapfile >= RAM size (30GB).

### 2. CPU & Process Management

#### Performance CPU Governor
**Location**: `machines/tower.nix`

```nix
powerManagement.cpuFreqGovernor = "performance";
```

**Benefits**:
- CPU stays at maximum frequency
- Eliminates frequency scaling latency
- Best for desktop/gaming workloads

**Trade-offs**: Higher power consumption (~10-20W more idle)

**Verification**:
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# All should show "performance"
```

**Alternative**: Use "schedutil" for balance between performance and power efficiency.

#### Gamemode Integration
**Location**: `machines/tower.nix`

```nix
programs.gamemode = {
  enable = true;
  settings = {
    general.renice = 10;
    gpu.apply_gpu_optimisations = "accept-responsibility";
  };
};
```

**Benefits**:
- Automatic CPU priority boost when gaming
- GPU performance state optimization
- Per-game performance tuning

**Usage**:
```bash
# Launch game with gamemode
gamemoderun your-game

# Or in Steam launch options:
gamemoderun %command%

# Check if gamemode is active:
gamemoded -s
```

### 3. Kernel Optimizations

#### Low-Latency Kernel Parameters
**Location**: `machines/tower.nix`

```nix
boot.kernelParams = [
  "mitigations=off"           # Disable CPU vulnerability mitigations
  "processor.max_cstate=1"    # Reduce CPU sleep state latency
  "nowatchdog"                # Disable kernel watchdog
  "tsc=reliable"              # Use TSC as clocksource
  "clocksource=tsc"           
  "transparent_hugepage=always"
  "ntsync.enable=1"           # Wine/Proton futex2 support
];
```

**Performance Gains**:
- `mitigations=off`: 5-10% CPU performance improvement
- `max_cstate=1`: Lower latency, faster wake from idle
- `ntsync`: 10-20% Wine/Proton performance boost

**Security Considerations**: 
`mitigations=off` disables Spectre/Meltdown protections. Acceptable for gaming desktop, but DO NOT use on servers or multi-tenant systems.

**Verification**:
```bash
cat /proc/cmdline | grep mitigations
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

#### System Tuning (sysctl)
**Location**: `machines/tower.nix`

```nix
boot.kernel.sysctl = {
  "vm.swappiness" = 10;              # Prefer RAM over swap
  "vm.vfs_cache_pressure" = 50;      # Keep more filesystem cache
  "vm.dirty_ratio" = 10;             # Write to disk sooner
  "vm.dirty_background_ratio" = 5;   
  "net.core.default_qdisc" = "fq";   # Fair queue scheduler
  "net.ipv4.tcp_congestion_control" = "bbr";  # Better TCP performance
};
```

**Benefits**:
- Desktop stays responsive under memory pressure
- Better filesystem cache utilization
- 10-30% network performance improvement with BBR

### 4. Storage & I/O Optimization

#### NVMe Kyber Scheduler
**Location**: `machines/tower.nix` (udev rules)

```bash
# NVMe drives use kyber (best for gaming/random I/O)
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="kyber"

# SATA SSDs use mq-deadline (better for sequential, QLC NAND)
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
```

**Benefits**:
- Kyber: Lower latency for gaming workloads on NVMe
- MQ-deadline: Better for QLC SATA SSDs (Samsung 870 QVO)

**Verification**:
```bash
cat /sys/block/nvme0n1/queue/scheduler  # Should show [kyber]
cat /sys/block/sda/queue/scheduler      # Should show [mq-deadline]
```

#### SSD-Optimized Mount Options
**Location**: `machines/tower.nix`

All filesystems now use:
```nix
options = [ "noatime" "nodiratime" "discard=async" "commit=60" ];
```

**Benefits**:
- `noatime`: No access time updates (reduces writes)
- `nodiratime`: No directory access time updates
- `discard=async`: Async TRIM for better performance
- `commit=60`: Batch writes every 60s (reduces SSD wear)

**SSD Lifespan Impact**: Can extend SSD life by 20-30% by reducing write amplification.

### 5. Boot Speed Optimizations

#### tmpfs for /tmp
**Location**: `machines/tower.nix`

```nix
boot.tmp.useTmpfs = true;
boot.tmp.tmpfsSize = "50%";
```

**Benefits**:
- /tmp operations at RAM speed
- No SSD writes for temporary files
- Saves 2-3 seconds on boot

**Trade-off**: Large temporary files consume RAM (capped at 50% = 15GB).

#### Reduced Boot Timeout
```nix
boot.loader.timeout = 3;  # Reduced from default 5s
```

**Saves**: 2 seconds on every boot.

#### Journal Size Limits
```nix
services.journald.extraConfig = ''
  SystemMaxUse=500M
  MaxRetentionSec=1week
'';
```

**Benefits**:
- Limits journal to 500MB (vs unlimited)
- Faster log queries
- Reduced disk usage

### 6. Gaming-Specific Optimizations

#### Wine/Proton Performance
**Location**: `home/hunter.nix`

```nix
home.sessionVariables = {
  WINEFSYNC = "1";  # Enable ntsync/futex2
  VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
};
```

**Benefits**:
- ntsync: 10-20% FPS improvement in DirectX games via Wine/Proton
- Vulkan ICD: Ensures games use NVIDIA GPU (important for hybrid systems)

#### Wayland Environment Variables
All Wayland apps properly configured:
```nix
MOZ_ENABLE_WAYLAND = "1";
NIXOS_OZONE_WL = "1";  # Chromium/Electron
QT_QPA_PLATFORM = "wayland";
SDL_VIDEODRIVER = "wayland";
```

### 7. Network Performance

#### TCP BBR Congestion Control
**Location**: `machines/tower.nix`

```nix
boot.kernel.sysctl = {
  "net.core.default_qdisc" = "fq";
  "net.ipv4.tcp_congestion_control" = "bbr";
  "net.ipv4.tcp_fastopen" = 3;
  "net.ipv4.tcp_mtu_probing" = 1;
};
```

**Benefits**:
- 10-30% better throughput on high-latency connections
- Lower latency for gaming
- Better handling of packet loss

**Verification**:
```bash
sysctl net.ipv4.tcp_congestion_control  # Should show bbr
sysctl net.core.default_qdisc           # Should show fq
```

## Performance Measurement

### Before/After Benchmarks

Run these commands to measure improvements:

```bash
# Boot time
systemd-analyze  # Target: <35s total

# Memory performance
sysbench memory run

# Disk I/O (run on NVMe)
fio --name=randread --ioengine=libaio --rw=randread --bs=4k --numjobs=1 --size=1G --runtime=60

# Network throughput
iperf3 -c <server>  # Should see improvement with BBR

# Gaming FPS
# Use MangoHud to monitor FPS before/after
mangohud your-game
```

### Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Boot Time | 41s | 33-35s | 15-20% |
| Gaming FPS | Baseline | +5-15% | Varies by game |
| System Responsiveness | Good | Excellent | Subjective |
| Network Latency | Baseline | -10-20ms | On high-latency links |
| SSD Writes/Day | High | Reduced 30% | Longer lifespan |

## Monitoring & Verification

### Check Active Optimizations

Create this verification script:

```bash
#!/usr/bin/env bash
# Performance tuning verification

echo "=== CPU Governor ==="
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

echo -e "\n=== zram Status ==="
zramctl

echo -e "\n=== I/O Schedulers ==="
echo "NVMe: $(cat /sys/block/nvme0n1/queue/scheduler)"
echo "SATA: $(cat /sys/block/sda/queue/scheduler)"

echo -e "\n=== TCP Congestion Control ==="
sysctl net.ipv4.tcp_congestion_control

echo -e "\n=== Kernel Parameters ==="
cat /proc/cmdline | grep -o 'mitigations=\w*'
cat /proc/cmdline | grep -o 'ntsync.enable=\w*'

echo -e "\n=== Memory Stats ==="
free -h

echo -e "\n=== Swap Priority ==="
swapon --show

echo -e "\n=== tmpfs Status ==="
df -h | grep tmpfs | grep -E '(tmp|run)'

echo -e "\n=== Gamemode Status ==="
systemctl status gamemode --no-pager 2>/dev/null || echo "Not running (normal when no games active)"
```

Save as `scripts/verify-performance.sh` and run after each rebuild.

## Reverting Changes

If you need to revert specific optimizations:

### Conservative Mode (Keep Security Mitigations)

Remove from `machines/tower.nix`:
```nix
# Comment out or remove:
# "mitigations=off"
# "processor.max_cstate=1"
```

Change CPU governor:
```nix
powerManagement.cpuFreqGovernor = "schedutil";  # Balanced
```

### Power Saving Mode

```nix
powerManagement.cpuFreqGovernor = "powersave";
boot.kernelParams = [
  # Remove performance-focused params
  "processor.max_cstate=5"  # Allow deeper C-states
];
```

## Troubleshooting

### Issue: System Runs Hot
**Solution**: Switch CPU governor to "schedutil" or "powersave"

### Issue: Out of Memory Errors
**Solution**: Reduce tmpfs size or disable:
```nix
boot.tmp.useTmpfs = false;
```

### Issue: Game Crashes with ntsync
**Solution**: Some older games may not work with ntsync. Remove from kernel params:
```nix
# Remove: "ntsync.enable=1"
```
And unset WINEFSYNC in home-manager.

### Issue: Network Performance Degraded
**Solution**: BBR may perform worse on very low-latency local networks. Switch back:
```nix
boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "cubic";
```

## References

- [NixOS Wiki: Performance Tuning](https://nixos.wiki/wiki/Performance_tuning)
- [Arch Wiki: Improving Performance](https://wiki.archlinux.org/title/Improving_performance)
- [Linux Gaming: ntsync/fsync](https://github.com/ValveSoftware/wine/wiki/Futex2)
- [TCP BBR Congestion Control](https://queue.acm.org/detail.cfm?id=3022184)
- [Linux I/O Schedulers](https://wiki.archlinux.org/title/Improving_performance#Storage_devices)

## Contributing

Found additional optimizations? See [CONTRIBUTING.md](CONTRIBUTING.md) for how to submit improvements.

---

**Last Updated**: January 2026  
**Configuration Version**: NixOS 24.11 (tower machine)
