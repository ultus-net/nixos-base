{ config, pkgs, lib, ... }:
{
  # Example machine that composes the master machine configuration and a
  # desktop profile. Replace `profiles/cosmic.nix` with a different profile
  # as required. This file is intended as a template for real machine
  # entries which can import an installer-generated `hardware-configuration.nix`.
  imports = [
    ./configuration.nix
    ../profiles/cosmic.nix
    ../modules/common-users.nix
  ];

  # Machine-specific identity
  networking.hostName = "example-machine";

  # Example: a single “primary” user managed by both NixOS (account) and
  # Home Manager (dotfiles, packages, user services).
  machines.users = {
    hunter = {
      isNormalUser = true;
      description = "Cameron Hunter";
      extraGroups = [ "wheel" "networkmanager" ];

      # IMPORTANT: replace this with a real hash before using on a real device.
      # Generate with: `mkpasswd -m sha-512` (from whois) or `openssl passwd -6`.
      initialHashedPassword = lib.mkDefault "";

      # For initial setup, you can also only set SSH authorized keys and keep
      # password login disabled (SSH is hardened in machines/configuration.nix).
      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA..."
      ];
    };
  };

  home-manager.users.hunter = import ../home/hunter.nix;

  # If you're installing onto a real device, generate hardware config with
  # `nixos-generate-config --root /mnt` and import the resulting
  # `hardware-configuration.nix` here before running `nixos-install`.
}

