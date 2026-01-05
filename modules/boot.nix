# Boot configuration module
{ config, pkgs, lib, ... }:

{
  # Bootloader configuration
  boot.loader = {
    # Use systemd-boot (recommended for UEFI systems)
    systemd-boot = {
      enable = true;
      configurationLimit = 10; # Limit number of generations in boot menu
    };
    
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    
    # Alternative: Use GRUB for legacy BIOS or more features
    # grub = {
    #   enable = true;
    #   device = "/dev/sda"; # For BIOS
    #   # efiSupport = true; # For UEFI
    #   # efiInstallAsRemovable = true; # For UEFI on removable media
    #   useOSProber = true; # Detect other operating systems
    # };
  };

  # Kernel parameters
  boot.kernelParams = [
    # Add any kernel parameters here
  ];

  # Enable latest kernel (optional)
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable support for additional filesystems
  boot.supportedFilesystems = [ "ntfs" "exfat" ];

  # Increase the maximum number of watchers
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
  };
}
