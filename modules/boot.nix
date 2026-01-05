{ config, pkgs, lib, ... }:
{
  boot = {
    # Fast and quiet boot with Plymouth
    plymouth = {
      enable = true;
      themePackages = [ pkgs.breeze-plymouth ];
      theme = "breeze";
    };
    kernelParams = [
      "quiet" "splash" "udev.log_level=3" "rd.udev.log_level=3"
    ];
    initrd.systemd.enable = true;
  };

  # Graphics/acceleration defaults
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Firmware updates
  services.fwupd.enable = true;
}
