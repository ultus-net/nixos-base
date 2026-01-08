{ config, pkgs, lib, ... }:
{
  # COSMIC desktop profile (System76 actual COSMIC desktop environment)
  #
  # This profile enables the real COSMIC desktop environment built by System76.
  # COSMIC is written in Rust and designed for modern Wayland compositing.
  #
  # NOTE: This requires the nixos-cosmic flake input to be configured.
  # Binary cache: https://cosmic.cachix.org/
  
  imports = [
    ../machines/configuration.nix
    ../modules/common-packages.nix
    ../modules/cosmic.nix
    ../modules/home-manager.nix
    ../modules/development.nix
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

  # Enable COSMIC desktop & greeter using built-in NixOS options
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Optional: keep COSMIC binary cache for faster builds (matches wiki recommendation)
  nix.settings = {
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  cosmic.enable = true;
  
  # Enable NixOS wallpaper collection by default
  machines.wallpapers.enable = lib.mkDefault true;
}
