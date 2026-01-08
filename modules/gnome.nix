{ config, pkgs, lib, ... }:
let
  cfg = config.gnome;
in {
  # GNOME desktop module: provide an opt-in toggle and an extraPackages option
  # so callers can add additional pkgs when GNOME is enabled.
  options.gnome = {
    enable = lib.mkEnableOption "Enable GNOME desktop (opt-in)";
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when GNOME is enabled.";
    };
    
    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "with pkgs; [ gnome-tour epiphany ]";
      description = "List of GNOME packages to exclude from the default installation.";
    };
    
    enableGDMWaylandByDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland session by default in GDM.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable X server and the GDM display manager with Wayland support.
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.gdm.wayland = cfg.enableGDMWaylandByDefault;
    services.desktopManager.gnome.enable = true;

    # Enable XWayland compatibility for X11 apps under Wayland.
    programs.xwayland.enable = true;
    
    # Enable dconf for GNOME apps configuration
    programs.dconf.enable = true;
    
    # Exclude unwanted packages
    environment.gnome.excludePackages = cfg.excludePackages;

    # Compose GNOME-specific packages from user-supplied extras and a few
    # standard GNOME utilities provided by nixpkgs.
    environment.systemPackages = (cfg.extraPackages or []) ++ (with pkgs; [
      gnome-calculator
      gnome-system-monitor
      gnome-terminal
      
      # Official NixOS wallpapers
      nixos-artwork.wallpapers.nineish-dark-gray
      nixos-artwork.wallpapers.simple-blue
      nixos-artwork.wallpapers.stripes-logo
      nixos-artwork.wallpapers.mosaic-blue
    ]);
  };
}
