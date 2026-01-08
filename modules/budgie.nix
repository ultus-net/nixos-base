{ config, pkgs, lib, ... }:
let
  cfg = config.budgie;
in {
  # Budgie desktop module (Solus Linux's desktop, GNOME-based)
  options.budgie = {
    enable = lib.mkEnableOption "Enable Budgie desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.budgie.enable = true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    
    programs.xwayland.enable = true;
    
    # Official NixOS wallpapers
    environment.systemPackages = with pkgs; [
      nixos-artwork.wallpapers.nineish-dark-gray
      nixos-artwork.wallpapers.simple-blue
      nixos-artwork.wallpapers.stripes-logo
      nixos-artwork.wallpapers.mosaic-blue
    ];
  };
}
