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
    
    # All optional feature modules
    ../modules/gaming.nix
    ../modules/multimedia.nix
    ../modules/virtualization.nix
    ../modules/containers.nix
  ];

  # Machine identity
  networking.hostName = "tower";

  # Primary user configuration
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Cameron Hunter";
      group = "hunter";  # Primary group
      extraGroups = [ 
        "wheel"           # sudo access
        "networkmanager"  # network configuration
        "video"           # access to video devices
        "audio"           # access to audio devices
        "docker"          # docker access
        "podman"          # podman access
        "libvirtd"        # VM management
        "kvm"             # KVM access
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
  
  # Better desktop responsiveness
  services.system76-scheduler.enable = true;
  
  # Additional system packages for tower workstation
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
    
    # Disk management
    gparted
    gnome-disk-utility
  ];
}
