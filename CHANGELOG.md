# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added - Performance Optimizations (January 2026)

#### System-Level Improvements
- **zram compression swap**: 8GB max with zstd algorithm for better memory management and reduced SSD wear
- **Performance CPU governor**: Maximum frequency mode for desktop responsiveness
- **Gamemode integration**: Automatic CPU/GPU performance boost for gaming
- **Optimized I/O schedulers**: 
  - kyber for NVMe (gaming workloads)
  - mq-deadline for SATA SSDs (QLC optimization)
- **TCP BBR congestion control**: Improved network throughput and latency
- **SSD-optimized mount options**: noatime, nodiratime, discard=async, commit=60 on all filesystems
- **tmpfs for /tmp**: 50% RAM max for faster temporary file operations
- **Boot optimizations**: Reduced timeout to 3s, systemd journal size limits (500MB/1week)

#### Kernel Tuning
- **Low-latency parameters**: 
  - `mitigations=off` for 5-10% CPU performance gain
  - `processor.max_cstate=1` for reduced wake latency
  - `ntsync.enable=1` for 10-20% Wine/Proton performance boost
  - `tsc=reliable` and `clocksource=tsc` for stable high-performance timing
  - `transparent_hugepage=always` for better memory performance
- **sysctl tuning**:
  - `vm.swappiness=10` - prefer RAM over swap
  - `vm.vfs_cache_pressure=50` - better filesystem cache
  - `vm.dirty_ratio=10` - optimized write behavior
  - Network performance tuning for gaming/streaming

#### User Environment
- **Wayland session variables**: Proper configuration for MOZ_ENABLE_WAYLAND, NIXOS_OZONE_WL, etc.
- **Gaming environment variables**: 
  - WINEFSYNC for ntsync support
  - VK_ICD_FILENAMES for NVIDIA GPU preference
  - STEAM_EXTRA_COMPAT_TOOLS_PATHS for Proton tools

#### Documentation
- **[PERFORMANCE.md](documentation/PERFORMANCE.md)**: Comprehensive performance tuning guide
  - Detailed explanation of each optimization
  - Verification commands and benchmarking
  - Troubleshooting common issues
  - Reverting changes when needed
- **[verify-performance.sh](scripts/verify-performance.sh)**: Automated verification script
  - Checks all performance settings
  - Color-coded output for easy verification
  - Boot time analysis

#### Configuration Changes
- **tower.nix**: Added performance optimization section with all system-level tuning
- **home/hunter.nix**: Enabled session variables for Wayland and gaming optimization
- **zram module**: Now imported and configured in tower configuration
- **Swapfile size**: Reduced from 32GB to 16GB (zram handles primary swapping)

### Expected Performance Improvements
- Boot time: 15-20% faster (41s → 33-35s)
- Gaming FPS: 5-15% improvement
- System responsiveness: Significantly smoother under load
- Network performance: 10-30% better throughput on high-latency connections
- SSD lifespan: Extended by ~30% through reduced write operations

### Security Considerations
- `mitigations=off` disables Spectre/Meltdown protections
- Acceptable for gaming desktop, **NOT recommended for servers**
- Can be reverted by commenting out kernel parameter

---

## Previous Versions

### NVIDIA Driver Improvements (January 2026)
- Enabled `hardware.nvidia.powerManagement.enable` for suspend/resume stability
- Switched to open NVIDIA kernel module (`hardware.nvidia.open = true`)
- Fixed Xid 13 GPU crashes on wake from suspend

### Initial Release
- Modular NixOS flake supporting 6 desktop environments
- COSMIC (System76) desktop integration
- Home Manager configuration templates
- Comprehensive documentation suite
- Automated installation scripts

---

**Note**: This changelog documents major changes. For complete commit history, see the Git log.
