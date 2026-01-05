{ config, pkgs, lib, ... }:
let
  cfg = config.commonPackages;
in {
  options.commonPackages = {
    enable = lib.mkEnableOption "Enable a small set of desktop-agnostic common packages";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages (package values from pkgs) to include in system-wide packages.";
    };
  };

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
