{ config, pkgs, lib, ... }:
{
  # Example machine that composes the master machine configuration and a
  # desktop profile. Replace `profiles/cosmic.nix` with a different profile
  # as required. This file is intended as a template for real machine
  # entries which can import an installer-generated `hardware-configuration.nix`.
  imports = [
    ./configuration.nix
    ../profiles/cosmic.nix
  ];

  # Machine-specific identity
  networking.hostName = "example-machine";

  # Create a local user (home-manager will manage dotfiles).
  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  # If you're installing onto a real device, generate hardware config with
  # `nixos-generate-config --root /mnt` and import the resulting
  # `hardware-configuration.nix` here before running `nixos-install`.
}
