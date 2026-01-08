{ config, pkgs, lib, ... }:

let
  cfg = config.machines.wallpapers;
  
  # Complete list of official NixOS wallpapers from nixos-artwork
  wallpaperPackages = with pkgs.nixos-artwork.wallpapers; [
    # Binary series
    binary-black
    binary-blue
    binary-red
    binary-white
    
    # Catppuccin series
    catppuccin-frappe
    catppuccin-latte
    catppuccin-macchiato
    catppuccin-mocha
    
    # Nineish series (retro style)
    nineish
    nineish-dark-gray
    nineish-solarized-dark
    nineish-solarized-light
    nineish-catppuccin-frappe
    nineish-catppuccin-frappe-alt
    nineish-catppuccin-latte
    nineish-catppuccin-latte-alt
    nineish-catppuccin-macchiato
    nineish-catppuccin-macchiato-alt
    nineish-catppuccin-mocha
    nineish-catppuccin-mocha-alt
    
    # Classic NixOS wallpapers
    simple-blue
    simple-dark-gray
    simple-light-gray
    simple-red
    mosaic-blue
    stripes
    stripes-logo
    
    # 3D renders
    dracula
    gear
    moonscape
    recursive
    waterfall
    watersplash
    
    # Other
    gnome-dark
    gradient-grey
  ];
  # Local wallpapers shipped in this repo (installed to /share/backgrounds).
  # Use the entire assets/wallpapers directory so you can add/remove images
  # without changing the module.
  localWallpapers = pkgs.stdenv.mkDerivation {
    name = "nixos-base-local-wallpapers";
    src = ./../assets/wallpapers;
    buildCommand = ''
      mkdir -p $out/share/backgrounds/nixos
      cp -a "$src"/* $out/share/backgrounds/nixos/ || true
    '';
  };
  
in
{
  options.machines.wallpapers = {
    enable = lib.mkEnableOption "NixOS official wallpaper collection with automatic rotation";
    
    rotationInterval = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Time in seconds between wallpaper changes";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Install only the local wallpapers package (from assets/wallpapers)
    environment.systemPackages = [ localWallpapers ];
    
    # Make wallpapers easily accessible via symlink
    environment.pathsToLink = [ "/share/backgrounds" ];
  };
}
