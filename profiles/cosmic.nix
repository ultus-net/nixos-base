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

    # Include the example machine so the top-level flake output evaluates
    # with a user + Home Manager config. For real installs, replace this by
    # using a `machines/<name>.nix` that imports hardware-configuration.nix.
    # Removed example machine import to avoid recursive import chain
    # ../machines/example-machine.nix
  ];

  # Desktop-focused package selection
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  # COSMIC-specific module (provided by ../modules/cosmic.nix)
}
