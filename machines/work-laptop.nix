{ config, pkgs, lib, ... }:
{
  # Work Laptop - Portable workstation with COSMIC desktop and DisplayLink support
  # Hardware configuration generated from nixos-generate-config

  imports = [
    ./configuration.nix
    ../profiles/cosmic.nix
    ../modules/common-users.nix
  ];

  # ============================================================================
  # Machine Identity
  # ============================================================================
  
  networking.hostName = "work-laptop";

  # ============================================================================
  # Regional Settings
  # ============================================================================
  
  # Set timezone to New Zealand
  time.timeZone = "Pacific/Auckland";

  # Locale settings for New Zealand
  i18n.defaultLocale = "en_NZ.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # ============================================================================
  # Hardware Configuration (from nixos-generate-config)
  # ============================================================================
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  # Temporarily disabled DisplayLink support - requires manual driver download
  boot.kernelModules = [ "kvm-intel" ];  # "evdi" removed for DisplayLink troubleshooting
  boot.extraModulePackages = [ ];  # evdi kernel module disabled

  # Use latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6d493940-1d4d-42d7-ba99-841432e67da2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5ABD-49CC";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/54112536-45a4-4494-9371-585008192b2b"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ============================================================================
  # COSMIC Desktop Configuration
  # ============================================================================
  
  cosmic.enableClipboardManager = true;
  cosmic.enableWaylandApps = true;
  cosmic.enableMediaControls = true;

  # ============================================================================
  # DisplayLink & Docking Station Support
  # ============================================================================
  
  # DisplayLink drivers for docking stations
  # Note: DisplayLink traditionally uses X11. For Wayland/COSMIC support, the evdi
  # kernel module is loaded, and XWayland provides compatibility for DisplayLink
  # displays. Future Wayland-native DisplayLink support may improve this.
  # Temporarily disabled DisplayLink - requires manual driver download from Synaptics
  services.xserver.videoDrivers = [ "modesetting" ];  # "displaylink" removed for troubleshooting

  # Enable Thunderbolt support for Thunderbolt docking stations
  services.hardware.bolt.enable = true;

  # ============================================================================
  # User Configuration
  # ============================================================================
  
  # Primary user configuration - reuse existing hunter user with home-manager
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Hunter";
      shell = pkgs.bash;
      group = "hunter";
      extraGroups = [
        "wheel"           # sudo access
        "networkmanager"  # network configuration
        "video"           # access to video devices
      ];

      # IMPORTANT: Set a real password after first boot!
      # Run: sudo passwd hunter
      initialHashedPassword = lib.mkDefault "";

      openssh.authorizedKeys.keys = [
        # Add your SSH public keys here for remote access
      ];
    };
  };

  # Home Manager configuration - reusing hunter.nix
  home-manager.users.hunter = import ../home/hunter.nix;

  # Create user group
  users.groups.hunter = {};

  # ============================================================================
  # Laptop Power Management & Optimizations
  # ============================================================================
  
  # SSD TRIM support
  services.fstrim.enable = true;
  
  # Firmware updates
  services.fwupd.enable = true;

  # Disable power-profiles-daemon since we're using TLP for advanced battery management
  services.power-profiles-daemon.enable = false;

  # TLP for advanced battery management
  services.tlp = {
    enable = true;
    settings = {
      # Battery charge thresholds (if supported by hardware)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU scaling governors
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Intel CPU energy performance policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Disable USB autosuspend for docking station reliability
      USB_AUTOSUSPEND = 0;

      # Disable Wake-on-LAN
      WOL_DISABLE = "Y";
    };
  };

  # Intel thermal management
  services.thermald.enable = true;

  # Better desktop responsiveness
  services.system76-scheduler.enable = true;

  # ============================================================================
  # Connectivity
  # ============================================================================
  
  # Bluetooth support - enabled by default on laptop
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ============================================================================
  # Input Devices
  # ============================================================================
  
  # Touchpad configuration with libinput
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      middleEmulation = true;
      disableWhileTyping = true;
    };
  };

  # ============================================================================
  # Services
  # ============================================================================
  
  # Printer support with CUPS
  services.printing.enable = true;
  
  # Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ============================================================================
  # System Packages
  # ============================================================================
  
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    powertop
    
    # Hardware utilities
    pciutils
    usbutils
    lm_sensors

    # Thunderbolt tools
    thunderbolt

    # DisplayLink support - temporarily disabled (requires manual driver download)
    # displaylink

    # Disk management
    gnome-disk-utility

    # Network tools
    networkmanagerapplet
  ];

}
