{ config, pkgs, lib, inputs, ... }:
{
  # KDE/Plasma desktop/profile. Keep machine specifics in `machines/`.
  imports = [
    ../machines/configuration.nix  # Import base machine config for boot/system defaults
    ../modules/common-packages.nix
    ../modules/kde.nix
    ../modules/home-manager.nix
    ../modules/wallpapers.nix
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

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.htop ];

  kde.enable = true;
  kde.enableWayland = true;
  
  # Enable NixOS wallpaper collection by default
  machines.wallpapers.enable = lib.mkDefault true;
}
