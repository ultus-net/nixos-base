{ config, pkgs, lib, ... }:
{
  # Enable our COSMIC developer QoL (standalone Home Manager example)
  # Note: On NixOS, Home Manager is already integrated via modules/home-manager.nix
  cosmicDev.enable = true;

  home.username = "csh"; # change if needed
  home.homeDirectory = "/home/csh"; # NixOS default path

  # State version (bump when migrating options)
  home.stateVersion = "24.11";
}
