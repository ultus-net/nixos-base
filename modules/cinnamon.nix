{ config, pkgs, lib, ... }:
let
  cfg = config.cinnamon;
in {
  # Cinnamon desktop module (Linux Mint's default desktop)
  options.cinnamon = {
    enable = lib.mkEnableOption "Enable Cinnamon desktop environment";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install with Cinnamon.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    
    programs.xwayland.enable = true;
    
    environment.systemPackages = cfg.extraPackages ++ (with pkgs; [
      # Official NixOS wallpapers
      nixos-artwork.wallpapers.nineish-dark-gray
      nixos-artwork.wallpapers.simple-blue
      nixos-artwork.wallpapers.stripes-logo
      nixos-artwork.wallpapers.mosaic-blue
    ]);
  };
}
