/*
  Master machine configuration for `machines/`.

  This file contains generic, installer-friendly defaults for machine
  deployments (locale, network manager/DHCP, zram, redistributable firmware,
  etc.). Machine entries in `machines/` should import this and then add
  device-specific settings (hostname, users, hardware-configuration.nix).
*/

{ config, pkgs, lib, ... }:
{
  # General, installer-friendly defaults; override in machine files as
  # needed per-machine.
  time.timeZone = lib.mkDefault "UTC";

  # Enable SSH to ease remote installation/testing (can be disabled after
  # setup).
  services.openssh.enable = lib.mkDefault true;

  # Harden SSH defaults when enabled.
  # - Disable password authentication (keys only)
  # - Disallow direct root login
  services.openssh.settings = {
    PasswordAuthentication = lib.mkDefault false;
    KbdInteractiveAuthentication = lib.mkDefault false;
    PermitRootLogin = lib.mkDefault "no";
  };

  # Enable redistributable firmware so hardware that requires non-free blobs
  # works across rebuilds. This is a safe, conservative default for desktops.
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Locale and keyboard defaults.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  # Networking defaults: prefer NetworkManager and DHCP for desktop-style
  # machines. Per-machine configs may disable NetworkManager and provide
  # static settings when required.
  networking.networkmanager.enable = lib.mkDefault true;

  # Use systemd-resolved by default for consistent DNS resolution across
  # environments.
  services.systemd-resolved.enable = lib.mkDefault true;

  # Provide a sensible default hostname that machines should override.
  networking.hostName = lib.mkDefault "nixos-host";

  # Desktop-friendly default for swap: enable zram-based swap. The zram
  # implementation and size are provided by the `modules/zram.nix` module;
  # import it here so the option is available and the service is installed.
  services.zram.enable = lib.mkDefault true;
  services.zram.swap.enable = lib.mkDefault true;

  # Import shared, reusable modules from `modules/`.
  imports = [ ../modules/zram.nix ];

  # Snapshot + GC retention:
  # - Keep 3 system generations (rollback points)
  # - Garbage collect store paths older than 14 days
  #
  # NixOS already provides nix-gc.service/timer; we configure it and avoid
  # defining custom units (systemd.services.* doesn't support hyphens in
  # attribute names via dot notation).
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };

  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 3;
}
