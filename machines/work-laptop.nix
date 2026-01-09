{ config, pkgs, lib, ... }:
{
  # Work Laptop - Portable workstation configuration
  # Generated from nixos-generate-config hardware scan

  imports = [
    ./configuration.nix
    ./work-laptop-hardware.nix  # Hardware configuration from nixos-generate-config

    # Desktop environment (you can change this to your preferred DE)
    ../profiles/gnome.nix

    # User management
    ../modules/common-users.nix
  ];

  # Machine identity
  networking.hostName = "work-laptop";

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

  # Use latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Primary user configuration
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Hunter";
      shell = pkgs.bash;  # Can change to zsh if preferred
      group = "hunter";
      extraGroups = [
        "wheel"           # sudo access
        "networkmanager"  # network configuration
        "video"           # access to video devices
        "audio"           # access to audio devices
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

  # Laptop-specific optimizations
  services.fstrim.enable = true;  # SSD TRIM support
  services.fwupd.enable = true;   # Firmware updates

  # Enable power management for laptops
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Better battery life with TLP (alternative to power-profiles-daemon)
  # Uncomment if you prefer TLP over power-profiles-daemon:
  # services.power-profiles-daemon.enable = false;
  # services.tlp.enable = true;
  # services.tlp.settings = {
  #   CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #   CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  # };

  # Enable thermald for Intel CPUs
  services.thermald.enable = true;

  # Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;  # Save battery

  # Printer support (CUPS)
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Network printer discovery
  };

  # Better desktop responsiveness
  services.system76-scheduler.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    powertop
    
    # Hardware utilities
    pciutils
    usbutils
    lm_sensors

    # Laptop utilities
    brightnessctl  # Screen brightness control
    acpi           # Battery status
  ];

  # System state version
  system.stateVersion = "25.11";
}
