{ config, pkgs, lib, inputs, ... }:
{
  # Desktop/profile for COSMIC — contains desktop-specific modules and
  # package bundles. This file intentionally avoids machine-specific
  # details (hostname, users, disks). Machine files should import this
  # profile and then add hardware-specific settings.
  imports = [
    ../modules/common-packages.nix
    ../modules/cosmic.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
    ../modules/development.nix
  ];

  # Desktop-focused package selection
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  # COSMIC-specific module (provided by ../modules/cosmic.nix)
}
