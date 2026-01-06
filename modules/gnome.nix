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
  };

  config = lib.mkIf cfg.enable {
    # Enable X server and the GDM display manager with Wayland support.
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Enable XWayland compatibility for X11 apps under Wayland.
    programs.xwayland.enable = true;

    # Compose GNOME-specific packages from user-supplied extras and a few
    # standard GNOME utilities provided by nixpkgs.
    environment.systemPackages = (cfg.extraPackages or []) ++ with pkgs; [
      gnome.gnome-calculator
      gnome.gnome-system-monitor
      gnome.gnome-terminal
    ];
  };
}
