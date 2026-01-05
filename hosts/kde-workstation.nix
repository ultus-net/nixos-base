{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../modules/common-packages.nix
    ../modules/kde.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  networking.hostName = "kde-workstation";
  time.timeZone = "UTC";

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.htop ];

  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  # Prefer Wayland on Plasma where available
  kde.enable = true;
  kde.enableWayland = true;

  services.openssh.enable = true;
}
