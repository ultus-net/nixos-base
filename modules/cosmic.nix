{ config, pkgs, lib, ... }:
{
  # COSMIC desktop fragment: enable the common session and desktop helpers.
  # This module focuses on enabling display/login services and small QoL
  # pieces that make the desktop usable out of the box.

  # X server and GDM: ensure the display manager and Wayland session are on.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Note: `services.xserver.desktopManager.cosmic` may be provided by a
  # downstream/custom module; if so, you can enable the cosmic desktop there.
  # services.xserver.desktopManager.cosmic.enable = true;

  # Wayland compatibility and desktop helpers
  programs.xwayland.enable = true; # provide X11 support under Wayland
  security.polkit.enable = true;   # polkit for privilege elevation dialogs
  programs.dconf.enable = true;    # manage dconf settings if needed

  # Small set of desktop applications and clipboard helper
  environment.systemPackages = with pkgs; [
    wl-clipboard
    gnome.gnome-calculator
    gnome.file-roller
    simple-scan
  ];

  # Note: prompt and user-level settings (starship, shell config) should be
  # configured via Home Manager (user-level) instead of system-level here.
}
