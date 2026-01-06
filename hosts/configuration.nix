/*
  Installer-friendly master configuration placed in `hosts/`.

  Purpose: this file holds general, host-agnostic defaults used during
  installation and by all workstation-specific host files. Treat this as the
  "master" configuration. Individual hosts (for example
  `cosmic-workstation.nix`) should import this file and then add desktop or
  hardware-specific settings.

  Example usage in a workstation file (top of the file):
    imports = [ ./configuration.nix ... ];

  Keep this file minimal and avoid device-specific boot options here; the
  installer can copy this to `/mnt/etc/nixos/configuration.nix` and then the
  machine-specific host file will be imported from there.
*/

{ config, pkgs, lib, ... }:
{
  # General, installer-friendly defaults; override in workstation files as
  # needed per-machine.
  time.timeZone = "UTC";

  # Enable SSH to ease remote installation/testing (can be disabled after
  # setup).
  services.openssh.enable = true;

  # Enable redistributable firmware so hardware that requires non-free blobs
  # works across rebuilds. This is a safe, conservative default for desktops.
  # (Admins may opt out if they need a fully free-only system.)
  # Note: don't force any particular GPU driver here — workstation files
  # should declare `services.xserver.videoDrivers` or other GPU options.
  hardware.enableRedistributableFirmware = true;

  # Locale and keyboard defaults. These are safe defaults and can be
  # overridden per-host if needed.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  # Networking defaults: prefer NetworkManager and DHCP for desktop-style
  # machines. Per-host configs may disable NetworkManager and provide
  # static settings when required.
  networking.networkmanager.enable = lib.mkDefault true;

  # Use systemd-resolved by default for consistent DNS resolution across
  # environments. Hosts may opt out if they manage DNS differently.
  services.systemd-resolved.enable = lib.mkDefault true;

  # Provide a sensible default hostname that hosts can override. Using
  # lib.mkDefault ensures workstation-specific files can replace this
  # without needing `override` semantics.
  networking.hostName = lib.mkDefault "nixos-host";

  # Desktop-friendly default for swap: enable zram-based swap. This is
  # conservative and works well across varied hardware; machines with
  # special swap requirements can override in their host files.
  services.zram.enable = lib.mkDefault true;
  services.zram.swap.enable = lib.mkDefault true;

  # NOTE: Avoid adding disk-specific bootloader options here unless this
  # configuration is being used directly on the target machine. Typical
  # UEFI options belong in a machine-specific file:
  #   boot.loader.systemd-boot.enable = true;
  #   boot.loader.efi.canTouchEfiVariables = true;

  # Keep root account as-is; set a password during installation with `passwd`.
}
