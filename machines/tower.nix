{ config, pkgs, lib, ... }:
{
  # Tower - Main home workstation with full feature set

  imports = [
    ./configuration.nix
    ./hardware-configuration.nix

    # Desktop environment
    ../profiles/cosmic.nix

    # User management
    ../modules/common-users.nix

    # Hardware modules
    ../modules/nvidia.nix

    # All optional feature modules
    ../modules/gaming.nix
    ../modules/multimedia.nix
    ../modules/virtualization.nix
    ../modules/containers.nix
    ../modules/zram.nix
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
      "discard=async"      # Enable TRIM support
      "commit=60"          # Write to disk every 60s (better for gaming loads)
    ];
  };

  # Kernel modules (uinput and I2C/SMBus for OpenRGB)
  boot.kernelModules = [
    "uinput"
    "i2c-dev"
    "i2c-piix4"  # common on AMD chipsets
    "i2c-i801"   # common on Intel chipsets
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

      # IMPORTANT: Set a real password hash before deploying!
      # Generate with: `mkpasswd -m sha-512` or `openssl passwd -6`
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
    };
  };

  # Enable NixOS official wallpaper collection with rotation
  machines.wallpapers.enable = true;
  machines.wallpapers.rotationInterval = 300;  # 5 minutes

  # ========================================================================
  # PERFORMANCE OPTIMIZATIONS
  # ========================================================================
  
  # Enable zram for better swap performance and reduced SSD wear
  # With 30GB RAM, this will use ~15GB zram (half of RAM, up to 4GB max default)
  machines.zram.enableAutoSize = true;
  machines.zram.maxSize = 8589934592; # 8GB max zram size
  machines.zram.compAlgorithm = "zstd"; # Better compression than lz4

  # CPU frequency governor for maximum performance
  powerManagement.cpuFreqGovernor = "performance";

  # Gaming & low-latency kernel optimizations
  boot.kernelParams = [
    # Disable CPU mitigations for ~5-10% performance gain (safe for gaming desktop)
    "mitigations=off"
    
    # Reduce CPU C-state latency for better responsiveness
    "processor.max_cstate=1"
    
    # Disable kernel watchdog (slight performance improvement)
    "nowatchdog"
    
    # Faster TSC clocksource (Zen 4 has stable TSC)
    "tsc=reliable"
    "clocksource=tsc"
    
    # Transparent Hugepages for better memory performance
    "transparent_hugepage=always"
    
    # Enable ntsync for improved Wine/Proton performance (Futex2)
    "ntsync.enable=1"
  ];

  # NVMe I/O scheduler optimization - kyber is best for gaming workloads
  # (better than mq-deadline for high-performance NVMe)
  services.udev.extraRules = ''
    # Enable USB device wakeup for all devices that support it
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
    
    # Set kyber I/O scheduler for NVMe drives (gaming optimization)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="kyber"
    
    # Keep mq-deadline for SATA SSDs (more conservative, better for QLC)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
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
    
    # Network performance
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  # Filesystem optimizations for SSDs
  fileSystems."/" = {
    options = [ "noatime" "nodiratime" "discard=async" "commit=60" ];
  };
  
  fileSystems."/boot" = {
    options = [ "noatime" "discard=async" ];
  };

  # COSMIC desktop personalization

  # Swap file configuration (reduced to 16GB since zram handles most swap needs)
  # Still useful as backup swap for hibernation if needed
  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # Size in MB (16GB)
    }
  ];
  cosmic.enableClipboardManager = true;
  cosmic.enableWaylandApps = true;
  cosmic.enableMediaControls = true;

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
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Better desktop responsiveness
  services.system76-scheduler.enable = true;

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
