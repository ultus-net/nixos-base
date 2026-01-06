{ config, pkgs, lib, ... }:
{
  # Laptop QoL: enable power management, thermals, input, bluetooth and portals
  # with brief comments explaining each option.

  # Global toggle for power management helpers (conservative default).
  powerManagement.enable = true;

  # Prefer the modern power-profiles-daemon; ensure TLP is not enabled at the
  # same time to avoid conflicts.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Enable Intel thermal daemon by default on systems where it's appropriate.
  services.thermald.enable = lib.mkDefault true;

  services.upower.enable = true; # battery/power reporting service

  # Bluetooth stack and Blueman UI for desktop Bluetooth management.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Use libinput for touchpad and general input device handling.
  services.libinput.enable = true;

  # XDG portal support improves sandboxed app integration (file pickers, etc.).
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # GTK portal backend
  };
}
