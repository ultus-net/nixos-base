{ config, pkgs, lib, ... }:
{
  # Boot module: configure boot UX, kernel params, graphics acceleration,
  # and firmware updates. Brief comments explain the purpose of each setting.

  boot = {
    # Plymouth provides a graphical splash on boot; choose a theme package
    # and enable the plymouth service to present a quieter boot experience.
    plymouth = {
      enable = true;
      themePackages = [ pkgs.breeze-plymouth ];
      theme = "breeze";
    };

    # Kernel command-line parameters: quiet/splash reduce kernel messages,
    # udev log levels reduce noisy device logs during early boot.
    kernelParams = [
      "quiet" "splash" "udev.log_level=3" "rd.udev.log_level=3"
    ];

    # Use systemd in the initramfs (helps with certain early boot features).
    initrd.systemd.enable = true;
  };

  # Graphics acceleration defaults: enable OpenGL and 32-bit DRI support
  # for applications that expect 32-bit drivers.
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Enable firmware update service for vendor firmware (fwupd).
  services.fwupd.enable = true;
}
