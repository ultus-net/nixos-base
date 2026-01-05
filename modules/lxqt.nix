{ config, pkgs, lib, ... }:
let
  cfg = config.lxqt;

  # Conservative default LXQt packages to include when available.
  desired = [ "pcmanfm-qt" "lxqt-panel" "qterminal" "pavucontrol-qt" "lxqt-session" "lxqt-runner" ];
  available = builtins.map (n: builtins.getAttr n pkgs)
    (builtins.filter (n: lib.hasAttr n pkgs) desired);
in {
  options.lxqt = {
    enable = lib.mkEnableOption "Enable LXQt desktop (opt-in)";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when LXQt is enabled.";
    };
    enableWayland = lib.mkEnableOption "Enable LXQt Wayland session if available";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
    # Choose a display manager; SDDM works well with Qt desktops
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.wayland = cfg.enableWayland;

    environment.systemPackages = (cfg.extraPackages or []) ++ available;
  };
}
