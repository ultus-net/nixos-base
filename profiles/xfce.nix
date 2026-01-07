{ config, pkgs, lib, inputs, ... }:
{
  # Xfce desktop profile
  imports = [
    ../machines/configuration.nix
    ../modules/common-packages.nix
    ../modules/xfce.nix
    ../modules/home-manager.nix
  ];

  # CRITICAL: Placeholder filesystem configuration for flake evaluation.
  # For real installations, you MUST replace these with your actual disk
  # configuration from nixos-generate-config --root /mnt. See INSTALL.md.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  xfce.enable = true;
}
