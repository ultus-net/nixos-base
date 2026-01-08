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

  # Set timezone to New Zealand
  time.timeZone = "Pacific/Auckland";

  # Primary user configuration
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Cameron Hunter";
      shell = pkgs.zsh;
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

  # Enable NixOS official wallpaper collection with rotation
  machines.wallpapers.enable = true;
  machines.wallpapers.rotationInterval = 300;  # 5 minutes

  # COSMIC desktop personalization
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

  # Better desktop responsiveness
  services.system76-scheduler.enable = true;

  # System-wide zsh shell support
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Additional system packages for tower workstation
  environment.systemPackages = with pkgs; [
    nixos-artwork.wallpapers.binary-black
    nixos-artwork.wallpapers.binary-blue
    nixos-artwork.wallpapers.binary-red
    nixos-artwork.wallpapers.binary-white
    nixos-artwork.wallpapers.catppuccin-frappe
    nixos-artwork.wallpapers.catppuccin-latte
    nixos-artwork.wallpapers.catppuccin-macchiato
    nixos-artwork.wallpapers.catppuccin-mocha
    nixos-artwork.wallpapers.nineish
    nixos-artwork.wallpapers.nineish-dark-gray
    nixos-artwork.wallpapers.nineish-solarized-dark
    nixos-artwork.wallpapers.nineish-solarized-light
    nixos-artwork.wallpapers.nineish-catppuccin-frappe
    nixos-artwork.wallpapers.nineish-catppuccin-frappe-alt
    nixos-artwork.wallpapers.nineish-catppuccin-latte
    nixos-artwork.wallpapers.nineish-catppuccin-latte-alt
    nixos-artwork.wallpapers.nineish-catppuccin-macchiato
    nixos-artwork.wallpapers.nineish-catppuccin-macchiato-alt
    nixos-artwork.wallpapers.nineish-catppuccin-mocha
    nixos-artwork.wallpapers.nineish-catppuccin-mocha-alt
    nixos-artwork.wallpapers.simple-blue
    nixos-artwork.wallpapers.simple-dark-gray
    nixos-artwork.wallpapers.simple-light-gray
    nixos-artwork.wallpapers.simple-red
    nixos-artwork.wallpapers.mosaic-blue
    nixos-artwork.wallpapers.stripes
    nixos-artwork.wallpapers.stripes-logo
    nixos-artwork.wallpapers.dracula
    nixos-artwork.wallpapers.gear
    nixos-artwork.wallpapers.moonscape
    nixos-artwork.wallpapers.recursive
    nixos-artwork.wallpapers.waterfall
    nixos-artwork.wallpapers.watersplash
    nixos-artwork.wallpapers.gnome-dark
    nixos-artwork.wallpapers.gradient-grey
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
