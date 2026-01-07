{ config, pkgs, lib, inputs, ... }:
{
  # Desktop/profile for GNOME-based developer workstation
  #
  # This is a GNOME/GDM configuration optimized for developers, not the
  # actual System76 COSMIC desktop environment. For real COSMIC, see
  # profiles/cosmic.nix instead.
  #
  # This file intentionally avoids machine-specific details (hostname, users,
  # disks). Machine files should import this profile and then add
  # hardware-specific settings.
  imports = [
    ../machines/configuration.nix  # Import base machine config for boot/system defaults
    ../modules/common-packages.nix
    ../modules/gnome-dev.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
    ../modules/development.nix

    # Include the example machine so the top-level flake output evaluates
    # with a user + Home Manager config. For real installs, replace this by
    # using a `machines/<name>.nix` that imports hardware-configuration.nix.
    # Removed example machine import to avoid recursive import chain
    # ../machines/example-machine.nix
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

  # Desktop-focused package selection
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  # GNOME-dev specific configuration (provided by ../modules/gnome-dev.nix)
}
