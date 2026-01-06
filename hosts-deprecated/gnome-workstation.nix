{ config, pkgs, lib, inputs, ... }:
{
  # GNOME workstation profile content (archived)
  imports = [
    ../modules/common-packages.nix
    ../modules/gnome.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
  ];

  networking.hostName = "gnome-workstation";

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  gnome.enable = true;
}
