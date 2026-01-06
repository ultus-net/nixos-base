{ config, pkgs, lib, ... }:
let
  cfg = config.commonPackages;
in {
  # Options for the common-packages module: an enable toggle and a list of
  # extra package values from `pkgs` to include in the system packages.
  options.commonPackages = {
    enable = lib.mkEnableOption "Enable a small set of desktop-agnostic common packages";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages (package values from pkgs) to include in system-wide packages.";
    };
  };

  # When enabled, compose the systemPackages list from any user-provided
  # packages plus a small pre-curated set of useful CLI tools and helpers.
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; (cfg.packages or []) ++ [
      # CLI tools useful regardless of desktop
      htop
      tmux
      ncdu
      unzip
      p7zip
      rsync
      openssh
      lsof
      strace

      # Nice-to-have inspectors / UX helpers
      btop
      neofetch
    ];
  };
}
