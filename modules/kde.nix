{ config, pkgs, lib, ... }:
let
  cfg = config.kde;

  # Conservative list of KDE/Plasma user-facing packages to install when
  # available in the current nixpkgs. We guard with lib.hasAttr so evaluation
  # won't fail on older/newer channels.
  desiredAttrs = [ "dolphin" "konsole" "okular" "kate" "kdeconnect" "breeze-icons" "kwrite" ];

  available = builtins.map (n: builtins.getAttr n pkgs)
    (builtins.filter (n: lib.hasAttr n pkgs) desiredAttrs);
in {
  options.kde = {
    enable = lib.mkEnableOption "Enable KDE Plasma (opt-in)";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when KDE is enabled.";
    };
    enableWayland = lib.mkEnableOption "Prefer Wayland session for Plasma if available";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.wayland = cfg.enableWayland;

    # Install user-specified extra packages (safe: user provides package values)
    environment.systemPackages = (cfg.extraPackages or []) ++ available;
  };
}
