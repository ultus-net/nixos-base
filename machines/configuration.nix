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

  # Ensure we keep a small number of system generations while still
  # deleting older store paths. The service below keeps the last 3 system
  # generations and then runs `nix-collect-garbage --delete-older-than 14d`.
  # This guarantees at least 3 generations are always available even if they
  # are older than 14 days.
  systemd.services.nixos-gc-keep-generations = {
    description = "Prune old system generations but keep last 3; run nix-collect-garbage";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "no";
      ExecStart = ''/bin/sh -e -c '\
        PROFILE=/nix/var/nix/profiles/system; \
        KEEP=3; \
        # get numeric generation IDs (strip any leading '*')\
        GENS=$(nix-env --list-generations --profile "$PROFILE" | awk '\''/^[[:space:]]*[0-9]+/{gsub("\\*","",$1); print $1}'\'' | sort -n || true); \
        if [ -n "$GENS" ]; then \
          MAX=$(echo "$GENS" | tail -n1); \
          if [ "$MAX" -gt "$KEEP" ]; then \
            THRESH=$((MAX - KEEP)); \
            echo "Deleting system generations 1..$THRESH"; \
            nix-env --profile "$PROFILE" --delete-generations "1-$THRESH" || true; \
          fi; \
        fi; \
        # Now run garbage collection to delete store paths older than 14 days
        nix-collect-garbage --delete-older-than 14d || true' '';
    };
  };

  systemd.timers.nixos-gc-keep-generations = {
    description = "Timer for nixos-gc-keep-generations";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = "true";
    };
  };

  # Use Nix garbage collection settings to keep device snapshots (profiles,
  # old generations, and unused GC roots) from accumulating indefinitely.
  # Enable automatic GC and default options to delete items older than 14 days.
  nix.gc.automatic = lib.mkDefault true;
  nix.gc.dates = lib.mkDefault [ "weekly" ];
  nix.gc.options = lib.mkDefault [ "--delete-older-than" "14d" ];
}
