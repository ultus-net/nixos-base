/*
  Installer-friendly configuration placed in `hosts/`.

  This is a small wrapper intended to be copied to
  `/mnt/etc/nixos/configuration.nix` during installation. It imports the
  host-specific `cosmic-dev.nix` sitting alongside it.
*/

{ config, pkgs, lib, ... }:
{
  # Import the host configuration that composes modules from `../modules/`.
  imports = [ ./cosmic-dev.nix ];

  # Minimal installer-friendly defaults; adjust as needed for your hardware.
  time.timeZone = "UTC";

  # Enable SSH to ease remote installation/testing (can be disabled afterwards).
  services.openssh.enable = true;

  # NOTE: Do not set disk-specific bootloader options here unless you know
  # the target machine. Typical options for UEFI-only machines are:
  #
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # fileSystems."/" = {
  #   device = "/dev/sdX1"; # replace with your root device
  #   fsType = "ext4";
  # };

  # Keep root account as-is; set a password during installation with `passwd`.
}
