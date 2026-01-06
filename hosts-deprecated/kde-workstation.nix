{ config, pkgs, lib, inputs, ... }:
{
  # KDE workstation profile content (archived)
  imports = [
    ../modules/common-packages.nix
    ../modules/kde.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  networking.hostName = "kde-workstation";

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.htop ];

  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  kde.enable = true;
  kde.enableWayland = true;
}
