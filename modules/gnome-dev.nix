{ config, pkgs, lib, ... }:
{
  # GNOME-based developer desktop module
  #
  # This is a GNOME/GDM configuration optimized for developers.
  # For the actual System76 COSMIC desktop environment, see modules/cosmic.nix
  # For pure GNOME, use modules/gnome.nix instead.
  #
  # This module provides a Wayland desktop with developer QoL features.

  # X server and GDM: ensure the display manager and Wayland session are on.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

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
    gnome-calculator
    file-roller
    simple-scan
  ];

  # Note: prompt and user-level settings (starship, shell config) should be
  # configured via Home Manager (user-level) instead of system-level here.
}
