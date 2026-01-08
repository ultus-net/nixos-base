{ config, pkgs, lib, ... }:
let
  cfg = config.xfce;
in {
  # XFCE desktop module (lightweight, traditional desktop)
  options.xfce = {
    enable = lib.mkEnableOption "Enable XFCE desktop environment";
    enableWaylandSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable XFCE Wayland session (experimental).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.desktopManager.xfce.enableWaylandSession = cfg.enableWaylandSession;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    
    programs.xwayland.enable = lib.mkIf cfg.enableWaylandSession true;
    
    # Official NixOS wallpapers
    environment.systemPackages = with pkgs; [
      nixos-artwork.wallpapers.nineish-dark-gray
      nixos-artwork.wallpapers.simple-blue
      nixos-artwork.wallpapers.stripes-logo
      nixos-artwork.wallpapers.mosaic-blue
    ];
  };
}
