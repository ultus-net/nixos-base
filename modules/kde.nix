{ config, pkgs, lib, ... }:
let
  cfg = config.kde;

  # Conservative list of KDE/Plasma package attribute names we try to include
  # when present in pkgs. We filter by presence to avoid evaluation errors
  # across different nixpkgs versions.
  desiredAttrs = [ "dolphin" "konsole" "okular" "kate" "kdeconnect" "breeze-icons" "kwrite" ];

  # Map available attribute names to actual package values.
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
    # Enable the Plasma 6 desktop and SDDM display manager with optional Wayland.
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = cfg.enableWayland;

    # Install extra user-provided packages plus the conservative KDE list.
    environment.systemPackages = (cfg.extraPackages or []) ++ available;
  };
}
