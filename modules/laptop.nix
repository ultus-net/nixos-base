{ config, pkgs, lib, ... }:
{
  # Laptop QoL: power, thermals, input, bluetooth, portals
  powerManagement.enable = true;

  # Prefer power-profiles-daemon over TLP (don’t enable both)
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Intel thermal daemon (safe on Intel laptops)
  services.thermald.enable = lib.mkDefault true;

  services.upower.enable = true;

  # Bluetooth + Blueman UI
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Touchpad and input tweaks
  services.libinput.enable = true;

  # Wayland portals for app integration
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
