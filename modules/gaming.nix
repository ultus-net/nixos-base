{ config, pkgs, lib, ... }:
let
  cfg = config.gaming;

  # A conservative list of package attribute names we want to include when
  # available on the current nixpkgs. We check for attribute presence so the
  # module can be evaluated across channels without failing on missing names.
  desiredAttrs = [
    "steam" "lutris" "steamcmd" "heroic" "gamescope" "mangohud"
    "vkbasalt" "latencyflex" "gamemode" "libFAudio" "vulkan-tools"
    "vulkan-loader" "wine" "protonup-qt" "protontricks" "winetricks"
    "obs_vkcapture" "mangohud-profiles"
  ];

  available = builtins.map (n: builtins.getAttr n pkgs)
    (builtins.filter (n: lib.hasAttr n pkgs) desiredAttrs);

  lib32Desired = [ "vulkan-loader" "libFAudio" ];
  lib32Available = if lib.hasAttr "lib32Packages" pkgs
    then builtins.map (n: builtins.getAttr n pkgs.lib32Packages)
           (builtins.filter (n: lib.hasAttr n pkgs.lib32Packages) lib32Desired)
    else [];
in {
  options.gaming = {
    enable = lib.mkEnableOption "Enable gaming QoL packages and helpers (opt-in)";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages (from pkgs) to include for gaming usage.";
    };

    enableI386Compat = lib.mkEnableOption "Add common i386/lib32 compatibility packages when available";
    enableFlatpaks = lib.mkEnableOption "Expose convenience notes for installing common Flatpaks (no automatic flatpak installs)";

    enableProtonEnv = lib.mkEnableOption "Write recommended Proton-related environment variables to the system environment";
    protonEnv = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Attribute set of environment variables to write when enableProtonEnv is true. Example: { PROTON_FSR4_UPGRADE = 1; }";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (cfg.packages or []) ++ available ++ (if cfg.enableI386Compat then lib32Available else []);

    # If requested, write Proton related environment variables to /etc/environment
    environment.variables = lib.mkIf cfg.enableProtonEnv cfg.protonEnv;
  };
}
