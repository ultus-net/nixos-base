{ config, pkgs, lib, inputs, ... }:
{
  # COSMIC workstation profile content (archived)
  imports = [
    ../modules/common-packages.nix
    ../modules/cosmic.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
    ../modules/development.nix
  ];

  networking.hostName = "cosmic-workstation";

  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  security.sudo.wheelNeedsPassword = false;
}
