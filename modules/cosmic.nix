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
    
    enableObservatory = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC Observatory system monitor (requires monitord)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the COSMIC desktop environment
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # XWayland support for legacy X11 apps
    programs.xwayland.enable = true;

    # Recommended: Flatpak for COSMIC Store
    services.flatpak.enable = lib.mkDefault true;
    
    # Enable clipboard manager protocol if requested
    environment.sessionVariables = lib.mkIf cfg.enableClipboardManager {
      COSMIC_DATA_CONTROL_ENABLED = "1";
    };
    
    # Enable Observatory system monitor if requested
    systemd.packages = lib.mkIf cfg.enableObservatory [ pkgs.observatory ];
    systemd.services.monitord = lib.mkIf cfg.enableObservatory {
      wantedBy = [ "multi-user.target" ];
    };

    # Small set of COSMIC-friendly utilities
    environment.systemPackages = with pkgs; [
      wl-clipboard
      foot  # Wayland terminal
    ];
  };
}
