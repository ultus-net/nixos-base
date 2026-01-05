{ config, pkgs, lib, ... }:
let
  cfg = config.gnome;
in {
  options.gnome = {
    enable = lib.mkEnableOption "Enable GNOME desktop (opt-in)";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when GNOME is enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.xwayland.enable = true;

    environment.systemPackages = (cfg.extraPackages or []) ++ with pkgs; [
      gnome.gnome-calculator
      gnome.gnome-system-monitor
      gnome.gnome-terminal
    ];
  };
}
