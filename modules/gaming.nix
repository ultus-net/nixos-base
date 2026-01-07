{ config, pkgs, lib, ... }:
let
  cfg = config.gaming;

  # Desired package attribute names to include when present in pkgs. We
  # filter by presence to make the module evaluation robust across
  # different nixpkgs snapshots (avoid evaluation-time errors).
  # NOTE: "steam" is excluded here; use gaming.enableSteam to enable it via programs.steam
  desiredAttrs = [
    "lutris" "steamcmd" "heroic" "gamescope" "mangohud"
    "vkbasalt" "latencyflex" "gamemode" "libFAudio" "vulkan-tools"
    "vulkan-loader" "wine" "protonup-qt" "protontricks" "winetricks"
    "obs_vkcapture" "mangohud-profiles"
  ];

  # Map the filtered attribute names to actual package values from pkgs.
  available = builtins.map (n: builtins.getAttr n pkgs)
    (builtins.filter (n: lib.hasAttr n pkgs) desiredAttrs);

  # List of 32-bit compatibility packages we want when available.
  lib32Desired = [ "vulkan-loader" "libFAudio" ];
  lib32Available = if lib.hasAttr "lib32Packages" pkgs
    then builtins.map (n: builtins.getAttr n pkgs.lib32Packages)
           (builtins.filter (n: lib.hasAttr n pkgs.lib32Packages) lib32Desired)
    else [];
in {
  options.gaming = {
    enable = lib.mkEnableOption "Enable gaming QoL packages and helpers (opt-in)";
    
    enableSteam = lib.mkEnableOption "Enable Steam via the NixOS programs.steam module";
    
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages (from pkgs) to include for gaming usage.";
    };

    # Toggle for installing common i386 (lib32) compatibility packages.
    enableI386Compat = lib.mkEnableOption "Add common i386/lib32 compatibility packages when available";

    # Informational toggle: if true, the module may expose instructions
    # or notes about Flatpaks (it does not install Flatpaks automatically).
    enableFlatpaks = lib.mkEnableOption "Expose convenience notes for installing common Flatpaks (no automatic flatpak installs)";

    # Proton environment helpers: write environment variables to the system
    # environment when requested (useful for Proton/Game compatibility tuning).
    enableProtonEnv = lib.mkEnableOption "Write recommended Proton-related environment variables to the system environment";
    protonEnv = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Attribute set of environment variables to write when enableProtonEnv is true. Example: { PROTON_FSR4_UPGRADE = 1; }";
    };
  };

  config = lib.mkIf cfg.enable {
    # Compose systemPackages from user-specified packages plus the available
    # gaming packages and optional lib32 compatibility packages.
    environment.systemPackages = (cfg.packages or []) ++ available ++ (if cfg.enableI386Compat then lib32Available else []);

    # Enable Steam via the proper NixOS module (avoids steam-unwrapped build issues)
    programs.steam = lib.mkIf cfg.enableSteam {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    
    # Enable 32-bit graphics drivers for Steam/Proton compatibility
    hardware.graphics.enable32Bit = lib.mkIf cfg.enableSteam true;

    # Optionally write Proton-related variables into the system environment
    # so they are available system-wide (use with care).
    environment.variables = lib.mkIf cfg.enableProtonEnv cfg.protonEnv;
  };
}
