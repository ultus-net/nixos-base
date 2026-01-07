{ config, pkgs, lib, ... }:
let
  cfg = config.lxqt;
in {
  # LXQt desktop module (lightweight Qt-based desktop)
  options.lxqt = {
    enable = lib.mkEnableOption "Enable LXQt desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    
    programs.xwayland.enable = true;
  };
}
