{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../modules/common-packages.nix
    ../modules/gnome.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  networking.hostName = "gnome-workstation";
  time.timeZone = "UTC";

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  gnome.enable = true;

  services.openssh.enable = true;
}
