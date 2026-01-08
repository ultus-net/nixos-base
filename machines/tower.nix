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

  # Automatically mount the dedicated games drive
  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/23fa1b43-1a18-48d6-ad19-6ce94dce6333";
    fsType = "ext4";
    # Make the volume show up clearly in GUI file managers
    options = [
      "x-gvfs-show"        # show as a drive in GVFS-based file managers
      "x-gvfs-name=Games" # display name "Games" in the sidebar
    ];
  };

  # Kernel modules (uinput and I2C/SMBus for OpenRGB)
  boot.kernelModules = [
    "uinput"
    "i2c-dev"
    "i2c-piix4"  # common on AMD chipsets
    "i2c-i801"   # common on Intel chipsets
  ];

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
