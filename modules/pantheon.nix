{ config, pkgs, lib, ... }:
let
  cfg = config.pantheon;
in {
  # Pantheon desktop module (elementary OS)
  options.pantheon = {
    enable = lib.mkEnableOption "Enable Pantheon desktop environment (elementary OS)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.desktopManager.pantheon.enable = true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
    services.xserver.displayManager.lightdm.greeters.pantheon.enable = lib.mkDefault true;
    
    programs.xwayland.enable = true;
  };
}
