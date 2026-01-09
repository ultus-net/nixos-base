{ config, pkgs, lib, ... }:
{
  # Hyprland desktop profile (Omarchy-style, opinionated)
  #
  # This profile enables the Hyprland desktop environment with Omarchy-inspired modular config.
  #
  # NOTE: This requires hyprland.nix to be present in the workspace.

  imports = [
    ../machines/configuration.nix
    ../modules/common-packages.nix
    ../modules/home-manager.nix
    ../modules/wallpapers.nix
    ../hyprland.nix
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

  # Enable Hyprland desktop
  hyprland.enable = true;

  # Enable NixOS wallpaper collection by default
  machines.wallpapers.enable = lib.mkDefault true;

  # Example: add common packages
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];
}
