{ config, pkgs, lib, ... }:
let
  cfg = config.kde;

  # Conservative list of KDE/Plasma package attribute names we try to include
  # when present in pkgs. We filter by presence to avoid evaluation errors
  # across different nixpkgs versions.
  desiredAttrs = [ 
    "dolphin" "konsole" "okular" "kate" "kdeconnect" 
    "breeze-icons" "kwrite" "kcalc" "kcharselect" 
    "kclock" "kcolorchooser" "ksystemlog"
  ];

  # Map available attribute names to actual package values.
  available = builtins.map (n: builtins.getAttr n pkgs.kdePackages)
    (builtins.filter (n: lib.hasAttr n pkgs.kdePackages) desiredAttrs);
in {
  options.kde = {
    enable = lib.mkEnableOption "Enable KDE Plasma (opt-in)";
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when KDE is enabled.";
    };
    
    enableWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prefer Wayland session for Plasma.";
    };
    
    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "with pkgs.kdePackages; [ elisa kpat ]";
      description = "List of KDE Plasma packages to exclude from the default installation.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the Plasma 6 desktop and SDDM display manager with optional Wayland.
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = cfg.enableWayland;
    
    # Exclude unwanted packages
    environment.plasma6.excludePackages = cfg.excludePackages;

    # Install extra user-provided packages plus the conservative KDE list.
    environment.systemPackages = (cfg.extraPackages or []) ++ available;
  };
}
