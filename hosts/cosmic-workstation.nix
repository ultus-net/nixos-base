{ config, pkgs, lib, inputs, ... }:
{
  # Import the master `configuration.nix` first, then compose the workstation
  # configuration from small, reusable module fragments located in
  # `modules/`.
  imports = [
    ./configuration.nix
    ../modules/common-packages.nix
    ../modules/cosmic.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
    ../modules/development.nix
  ];

  # Basic machine identity — kept per-host so the master file remains generic.
  networking.hostName = "cosmic-workstation";

  # Enable common package bundle and add a couple extras for convenience
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  # Make sure a local user exists (home-manager will manage dotfiles)
  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  # Relax sudo for developer convenience on this example host (optional)
  security.sudo.wheelNeedsPassword = false;
}
