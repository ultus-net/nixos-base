{ config, pkgs, lib, ... }:
let
  cfg = config.sysadmin;
in {
  options.sysadmin = {
    enable = lib.mkEnableOption "Enable system administration and maintenance tools (opt-in)";
    
    enableBackupTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install backup and sync tools (restic, rclone, syncthing)";
    };
    
    enableNetworkDiagnostics = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install network diagnostic and monitoring tools";
    };
    
    enableHardwareMonitoring = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install hardware monitoring and diagnostic tools";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional sysadmin packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Archive & Compression (extended formats beyond common-packages)
      unrar        # RAR archives
      zstd         # Fast compression
      
      # Disk & Filesystem Tools
      parted gptfdisk   # Disk partitioning
      e2fsprogs        # ext2/3/4 tools
      dosfstools       # FAT/FAT32 tools
      ntfs3g           # NTFS support
      exfatprogs       # exFAT support
      
      # Process Management
      killall
      psmisc           # fuser, killall, pstree
      procps           # ps, top, vmstat
      
      # Modern System Tools
      procs            # Better ps
      duf              # Better df (disk usage)
      dust             # Better du (directory size)
      
    ] ++ lib.optionals cfg.enableBackupTools [
      restic           # Modern backup tool
      rclone           # Cloud storage sync
      syncthing        # P2P file sync
      borgbackup       # Deduplicated backups
    ] ++ lib.optionals cfg.enableNetworkDiagnostics [
      # Network Diagnostics
      inetutils        # telnet, ftp, etc.
      dnsutils         # dig, nslookup
      traceroute       # Network path tracing
      bandwhich        # Network bandwidth monitor
      dogdns           # Better dig
      gping            # Ping with graph
      iperf3           # Network performance
      tcpdump          # Packet analyzer
      wireshark        # GUI packet analyzer
      nmap             # Network scanner
    ] ++ lib.optionals cfg.enableHardwareMonitoring [
      # Hardware Monitoring & Information
      inxi             # Full system information
      hwinfo           # Hardware detection
      smartmontools    # Hard drive health (SMART)
      dmidecode        # DMI table decoder
      lm_sensors       # Hardware sensors
      nvme-cli         # NVMe management
      hdparm           # Hard disk parameters
      usbutils         # lsusb and USB tools
      pciutils         # lspci and PCI tools
    ] ++ cfg.extraPackages;
    
    # Enable SMART monitoring daemon
    services.smartd = lib.mkIf cfg.enableHardwareMonitoring {
      enable = lib.mkDefault true;
    };
  };
}
