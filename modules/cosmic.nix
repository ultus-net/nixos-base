{ config, pkgs, lib, ... }:
{
  # COSMIC Desktop session 
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  # The `cosmic` desktop manager option may not exist in upstream NixOS.
  # If you have a custom module that exposes this, keep it; otherwise
  # enable a supported desktop manager (gnome/plasma) or configure the
  # session via `services.xsession.windowManager`/`displayManager`.
  # services.xserver.desktopManager.cosmic.enable = true;

  # Wayland & desktop QoL
  programs.xwayland.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;

  # Handy desktop apps & clipboard
  environment.systemPackages = with pkgs; [
    wl-clipboard
    gnome.gnome-calculator
    gnome.file-roller
    simple-scan
  ];

  # Prompt (user-level configuration like starship should be managed via
  # Home Manager; keep starship in `home.packages` or enable it there.)
}
