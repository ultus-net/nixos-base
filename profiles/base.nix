{ config, pkgs, lib, inputs, ... }:
{
  # Minimal headless base profile for servers and non-graphical installations.
  # This provides a solid foundation with essential tools but no desktop environment.
  #
  # Suitable for:
  # - Servers (web, database, application)
  # - Containers and VMs
  # - Headless development machines
  # - Network infrastructure (routers, firewalls)
  #
  # Machine-specific details (hostname, users, hardware configuration) belong
  # in `machines/` entries that import this profile.

  imports = [
    ../machines/configuration.nix  # Base machine config (boot, locale, SSH, etc.)
    ../modules/common-packages.nix # Essential CLI tools
    ../modules/security.nix        # Security hardening
    ../modules/networking.nix      # Network management
    ../modules/zram.nix            # Compressed swap (useful on all systems)
    ../modules/home-manager.nix    # Optional: Home Manager integration
  ];

  # CRITICAL: Placeholder filesystem configuration for flake evaluation.
  # For real installations, you MUST replace these with your actual disk
  # configuration from `nixos-generate-config --root /mnt`. See INSTALL.md.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  # Enable essential packages
  commonPackages.enable = true;
  commonPackages.packages = with pkgs; [
    git
    curl
    wget
    vim
    tmux
  ];

  # Security hardening is applied via modules/security.nix import above
  # (firewall, SSH agent, avahi, etc.)

  # ZRAM swap configuration (using machines.zram.* options from modules/zram.nix)
  # The module auto-sizes zram based on available RAM
  machines.zram.enableAutoSize = true;
  machines.zram.maxSize = 4294967296; # 4GiB max

  # Headless systems typically don't need audio or fonts
  # (These are not imported above, so they won't be available)

  # For development work on headless systems, uncomment:
  # imports = [ ../modules/development.nix ];
  # development.enable = true;

  # For containerized workloads, uncomment:
  # imports = [ ../modules/containers.nix ];
  # containers.enable = true;

  # For virtualization host, uncomment:
  # imports = [ ../modules/virtualization.nix ];
  # virtualization.enable = true;

  # For sysadmin tools (backups, monitoring, diagnostics), uncomment:
  # imports = [ ../modules/sysadmin.nix ];
  # sysadmin.enable = true;
}
