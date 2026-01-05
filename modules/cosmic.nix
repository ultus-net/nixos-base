{ config, pkgs, lib, ... }:
{
  # COSMIC Desktop session
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.cosmic.enable = true;

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

  # Prompt
  programs.starship.enable = true;
}
