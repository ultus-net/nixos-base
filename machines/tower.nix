{ config, pkgs, lib, ... }:
{
  # Tower - Main home workstation with full feature set

  imports = [
    ./configuration.nix
    ./hardware-configuration.nix

    # Desktop environment - Switched to KDE for stability
    ../profiles/kde.nix

    # User management
    ../modules/common-users.nix

    # Hardware modules
    ../modules/nvidia.nix

    # Security module can now be safely imported with KDE
    ../modules/security.nix

    # All optional feature modules
    ../modules/gaming.nix
    ../modules/multimedia.nix
    ../modules/virtualization.nix
    ../modules/containers.nix
    # NOTE: zram.nix is already imported via configuration.nix
  ];

  # Machine identity
  networking.hostName = "tower";

  # Set timezone to New Zealand
  time.timeZone = "Pacific/Auckland";

  # Automatically mount the dedicated games drive
  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/23fa1b43-1a18-48d6-ad19-6ce94dce6333";
    fsType = "ext4";
    # Make the volume show up clearly in GUI file managers
    options = [
      "x-gvfs-show"        # show as a drive in GVFS-based file managers
      "x-gvfs-name=Games"  # display name "Games" in the sidebar
      "noatime"            # SSD optimization
      "nodiratime"         # SSD optimization
      "discard"            # Enable TRIM support
      "commit=60"          # Write to disk every 60s (better for gaming loads)
    ];
  };

  # Kernel modules (uinput and I2C/SMBus for OpenRGB, AMD P-State for performance)
  boot.kernelModules = [
    "uinput"
    "i2c-dev"
    "i2c-piix4"  # common on AMD chipsets
    "i2c-i801"   # common on Intel chipsets
    "fuse"       # FUSE for AppImage mounting
    "amd_pstate_epp"  # AMD P-State EPP driver for Zen 4 performance
  ];

  # Boot optimizations
  boot.loader.timeout = 3; # Faster boot menu timeout (default is 5s)
  
  # Use tmpfs for /tmp (faster, saves SSD writes)
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Use up to 50% of RAM for /tmp
  
  # Systemd journal size limits (prevent excessive disk usage)
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=1week
  '';

  # Primary user configuration
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Hunter";
      shell = pkgs.zsh;
      group = "hunter";  # Primary group
      extraGroups = [
        "wheel"           # sudo access
        "networkmanager"  # network configuration
        "video"           # access to video devices
        "audio"           # access to audio devices
        "docker"          # docker access
        "libvirtd"        # VM management
        "kvm"             # KVM access
        "i2c"             # access to /dev/i2c-* devices
        "bluetooth"       # bluetooth device management
      ];

      # CRITICAL: Set a real password hash before deploying to production!
      # Generate with: nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
      # An empty hash allows passwordless login - INSECURE for production!
      initialHashedPassword = lib.mkDefault "";

      openssh.authorizedKeys.keys = [
        # Add your SSH public keys here
      ];
    };
  };

  # Home Manager configuration
  home-manager.users.hunter = import ../home/hunter.nix;

  # Create user group
  users.groups.hunter = {};

  # Enable all optional feature modules
  gaming.enable = true;
  gaming.enableSteam = true;  # Use programs.steam for proper Steam integration
  multimedia.enable = true;
  virtualization.enable = true;
  machines.containers.enable = true;

  # KDE Plasma 6 configuration
  kde.enable = true;
  kde.enableWayland = true;
  kde.enableKDEConnectFirewall = true;
  kde.enableBluetoothManager = true;
  kde.disableBaloo = false;  # Keep indexing for better file search
  kde.enableKWalletPAM = true;
  kde.optimizeFonts = true;
  kde.valveTheme.enable = true;  # Valve/Half-Life theming support

  # Gamemode for automatic performance boosting in games
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10; # Prioritize games
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0; # Primary GPU (RTX 3070)
        amd_performance_level = "high"; # For AMD iGPU if used
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode Started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode Ended'";
      };
    };
  };
  
  # Enhanced NVIDIA settings for RTX 3070 gaming
  hardware.nvidia = {
    # Enable nvidia-settings GUI
    nvidiaSettings = true;
    
    # Force full composition pipeline off for lower latency
    forceFullCompositionPipeline = false;
    
    # Enable power management for better performance/power balance
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # Not supported on RTX 3070
  };

  # Enable NixOS official wallpaper collection with rotation
  machines.wallpapers.enable = true;
  machines.wallpapers.rotationInterval = 300;  # 5 minutes

  # ========================================================================
  # PERFORMANCE OPTIMIZATIONS
  # ========================================================================
  # 
  # Hardware: AMD Ryzen 5 7600 (6C/12T), RTX 3070, 30GB RAM, NVMe + SSD
  # Focus: Gaming, multitasking, low latency, high throughput
  # 
  # Key optimizations:
  # - AMD Zen 4 specific: P-State EPP, preferred core, optimized C-states
  # - 50% zram (~15GB) for efficient memory compression
  # - IRQ balancing for multi-core efficiency
  # - Enhanced network buffers for gaming/streaming
  # - NVMe-optimized I/O and memory management
  # - Reduced swap (4GB disk + 15GB zram) with 30GB RAM
  # - Performance CPU governor with frequency boost
  # - System76 scheduler + GameMode integration
  # ========================================================================
  
  # Enable zram for better swap performance and reduced SSD wear
  # Uses official NixOS zramSwap module instead of custom implementation
  zramSwap = {
    enable = true;
    algorithm = "zstd";       # Better compression ratio than lz4
    memoryPercent = 50;       # Use 50% of RAM (~15GB on 30GB system) - you have plenty
    priority = 100;           # Higher priority than disk swap
  };

  # CPU frequency governor for maximum performance
  powerManagement.cpuFreqGovernor = "performance";

  # Gaming & low-latency kernel optimizations
  boot.kernelParams = [
    # WARNING: Disabling CPU mitigations improves performance by ~5-10% but
    # exposes the system to Spectre/Meltdown attacks. Only use on isolated
    # gaming desktops that don't run untrusted code. For security, use:
    # "mitigations=auto"
    "mitigations=off"
    
    # Disable kernel watchdog (slight performance improvement)
    "nowatchdog"
    
    # Transparent Hugepages for better memory performance
    "transparent_hugepage=always"
    
    # AMD Zen 4 specific optimizations
    "amd_pstate=active"  # Use AMD P-State EPP driver for better power/perf
    "amd_prefcore=enable"  # Enable preferred core ranking (boost best cores)
    
    # Reduce C-state latency for gaming (Zen 4 specific)
    "processor.max_cstate=2"  # Balance between performance and power
    
    # TSC clocksource for lower latency (Ryzen 7600 has stable TSC)
    "tsc=reliable"
    "clocksource=tsc"
    
    # Memory performance - Zen 4 has excellent memory controller
    "amd_iommu=on"
    "iommu=pt"  # Pass-through mode for better performance with VMs
  ];

  # I/O scheduler optimization for gaming workloads
  # Use kyber if available (best for high-performance NVMe), otherwise use none
  services.udev.extraRules = ''
    # Enable USB device wakeup for all devices that support it
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
    
    # Set I/O scheduler for NVMe drives - try kyber first, fall back to none
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", TEST=="queue/scheduler", ATTR{queue/scheduler}="none"
  '';

  # TCP BBR congestion control for faster networking
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # Desktop responsiveness tuning
    "vm.swappiness" = 10; # Reduce swap usage (we have plenty of RAM)
    "vm.vfs_cache_pressure" = 50; # Keep more filesystem cache
    
    # Gaming optimizations
    "vm.dirty_ratio" = 10; # Write to disk sooner (better for gaming)
    "vm.dirty_background_ratio" = 5;
    
    # Better memory management for 30GB RAM system
    "vm.min_free_kbytes" = 262144;  # Keep 256MB free (good for high RAM)
    "vm.dirty_expire_centisecs" = 3000;  # 30 seconds
    "vm.dirty_writeback_centisecs" = 1500;  # 15 seconds
    
    # Network performance
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;
    
    # Gaming-specific network tuning
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_sack" = 1;
    "net.core.rmem_max" = 134217728;  # 128MB receive buffer
    "net.core.wmem_max" = 134217728;  # 128MB send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";  # TCP read buffer
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";  # TCP write buffer
    
    # Reduce swap tendency (with 30GB RAM, rarely need swap)
    "vm.watermark_scale_factor" = 200;  # Scale down memory reclaim
    
    # Better for NVMe drives
    "vm.page-cluster" = 0;  # Disable read-ahead clustering (NVMe is fast enough)
    
    # Audio/Video streaming optimizations
    "net.core.optmem_max" = 65536;
    
    # Better multi-core scheduling (Ryzen 5 7600 has 6 cores)
    "kernel.sched_migration_cost_ns" = 5000000;  # 5ms
    "kernel.sched_autogroup_enabled" = 0;  # Disable for better gaming perf
  };

  # Filesystem optimizations for SSDs
  # These options are merged with hardware-configuration.nix
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "commit=60" ];
  
  # For FAT /boot partition, only add noatime (preserve fmask/dmask from hardware-configuration.nix)
  fileSystems."/boot".options = lib.mkAfter [ "noatime" ];

  # COSMIC desktop personalization

  # Swap file as fallback (zram handles primary swap needs)
  # With 30GB RAM + 15GB zram, disk swap rarely needed
  # For hibernation: swap size should equal RAM (30GB). Without hibernation,
  # 4GB is sufficient as emergency overflow. Set to 0 to disable if not needed.
  swapDevices = [
    {
      device = "/swapfile";
      size = 4096; # Size in MB (4GB) - emergency overflow only
      priority = 10; # Lower priority than zram (higher number = lower priority)
    }
  ];

  # Workstation optimizations
  services.fstrim.enable = true;  # SSD TRIM support
  services.fwupd.enable = true;   # Firmware updates

  # Printer support
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Network printer discovery
  };

  # Bluetooth support
  # COSMIC desktop includes built-in Bluetooth settings, so blueman is not needed
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # services.blueman.enable = true; # Uncomment if you prefer blueman over COSMIC's Bluetooth UI

  # Better desktop responsiveness
  services.system76-scheduler.enable = true;
  
  # IRQ balancing for better multi-core performance (important for 6-core Ryzen)
  services.irqbalance.enable = true;

  # System-wide zsh shell support
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Additional system packages for tower workstation
  # (wallpapers are now provided via assets/wallpapers and the
  #  machines.wallpapers module, so we no longer install the
  #  nixos-artwork wallpaper packages here.)
  environment.systemPackages = with pkgs; [
    # System monitoring and management
    htop
    btop
    iotop
    powertop

    # Hardware utilities
    pciutils
    usbutils
    lm_sensors

    # RGB managers
    openrgb

    # FUSE runtime for AppImages
    fuse
    fuse3

    # AccountsService package (provides accounts-daemon)
    accountsservice

    # Disk management
    gparted
    gnome-disk-utility
  ];

  # Autostart OpenRGB for graphical sessions (system-wide)
  environment.etc."xdg/autostart/openrgb.desktop".text = ''
[Desktop Entry]
; Auto-start OpenRGB for desktop sessions
Type=Application
Name=OpenRGB
Exec=${pkgs.openrgb}/bin/OpenRGB -p tower-openrgb.orp
X-GNOME-Autostart-enabled=true
NoDisplay=false
'';

  # Let NixOS install OpenRGB's udev rules properly
  services.udev.packages = [ pkgs.openrgb ];

  # ckb-next removed for unsupported Lighting Node CORE; use OpenRGB instead
}
