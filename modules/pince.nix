{ config, pkgs, lib, ... }:

let
  cfg = config.pince;
  pincePkg = pkgs.callPackage ../pkgs/pince {};
in {
  options.pince = {
    enable = lib.mkEnableOption "Install PINCE (built from source) as a system package";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pincePkg ];
  };
}
