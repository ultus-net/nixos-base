{ inputs, lib, config, pkgs, ... }:
{
  # Integrate Home Manager into NixOS.
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Global flags for Home Manager.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}

