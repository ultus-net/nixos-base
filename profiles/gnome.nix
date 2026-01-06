{ config, pkgs, lib, inputs, ... }:
{
  # GNOME desktop/profile. Machine-specific details (hostname, users,
  # hardware mounts) belong in `machines/` entries that import this file.
  imports = [
    ../modules/common-packages.nix
    ../modules/gnome.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  gnome.enable = true;
}
