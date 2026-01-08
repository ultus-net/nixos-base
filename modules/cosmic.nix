{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.cosmic;
in {
  # Real COSMIC desktop environment module (System76)
  #
  # This module enables the actual COSMIC desktop environment using the
  # nixos-cosmic flake from https://github.com/lilyinstarlight/nixos-cosmic
  #
  # COSMIC is the next-generation desktop environment from System76, built
  # in Rust with a focus on performance, customization, and Wayland support.

  options.cosmic = {
    enable = lib.mkEnableOption "Enable COSMIC desktop environment (System76)";

    enableClipboardManager = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC clipboard manager (requires zwlr_data_control_manager_v1 protocol)";
    };

    enableMediaControls = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable media controls in the COSMIC top panel";
    };



    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to install for COSMIC desktop";
      example = lib.literalExpression "[ pkgs.cosmic-files pkgs.cosmic-edit ]";
    };

    enableWaylandApps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install recommended Wayland-native applications";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the COSMIC desktop environment
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # XWayland support for legacy X11 apps
    programs.xwayland.enable = true;

    # Enable clipboard manager protocol if requested
    environment.sessionVariables = lib.mkIf cfg.enableClipboardManager {
      COSMIC_DATA_CONTROL_ENABLED = "1";
    };



    # Small set of COSMIC-friendly utilities
    environment.systemPackages = with pkgs; [
      wl-clipboard      # Wayland clipboard utilities
      wl-clip-persist   # Keep clipboard after app closes
      wtype             # Wayland keyboard input emulator
      grim              # Screenshot tool
      slurp             # Region selector for screenshots
      swappy            # Screenshot editor

      # Official NixOS wallpapers
      nixos-artwork.wallpapers.nineish-dark-gray
      nixos-artwork.wallpapers.simple-blue
      nixos-artwork.wallpapers.stripes-logo
      nixos-artwork.wallpapers.mosaic-blue

      # Additional Wayland apps if enabled
    ] ++ lib.optionals cfg.enableWaylandApps [
      nautilus          # File manager (works great on Wayland)
      loupe             # Image viewer
      papers            # PDF viewer
      gnome-calculator
      gnome-calendar
      gnome-contacts
      gnome-weather
      gnome-clocks
    ] ++ cfg.extraPackages ++ lib.optionals cfg.enableMediaControls [
      pkgs.cosmic-panel
      pkgs.cosmic-applets
      pkgs.cosmic-player
    ];

    # Font configuration for better rendering
    fonts.fontconfig = {
      enable = lib.mkDefault true;
      antialias = lib.mkDefault true;
      hinting.enable = lib.mkDefault true;
      hinting.style = lib.mkDefault "slight";
      subpixel.rgba = lib.mkDefault "rgb";
    };
  };
}
