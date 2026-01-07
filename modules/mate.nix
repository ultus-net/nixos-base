{ config, pkgs, lib, ... }:
let
  cfg = config.mate;
in {
  # MATE desktop module (GNOME 2 fork, traditional desktop)
  options.mate = {
    enable = lib.mkEnableOption "Enable MATE desktop environment";
    enableWaylandSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MATE Wayland session (experimental, requires Wayfire).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.mate.enable = true;
    services.xserver.desktopManager.mate.enableWaylandSession = cfg.enableWaylandSession;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    
    programs.xwayland.enable = lib.mkIf cfg.enableWaylandSession true;
  };
}
