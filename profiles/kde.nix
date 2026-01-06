{ config, pkgs, lib, inputs, ... }:
{
  # KDE/Plasma desktop/profile. Keep machine specifics in `machines/`.
  imports = [
    ../modules/common-packages.nix
    ../modules/kde.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.htop ];

  kde.enable = true;
  kde.enableWayland = true;
}
