{ config, pkgs, lib, ... }:
{
  # Archived master configuration that used to live at hosts/configuration.nix
  time.timeZone = "UTC";
  services.openssh.enable = true;
  hardware.enableRedistributableFirmware = true;
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";
  networking.networkmanager.enable = lib.mkDefault true;
  services.systemd-resolved.enable = lib.mkDefault true;
  networking.hostName = lib.mkDefault "nixos-host";
  services.zram.enable = lib.mkDefault true;
  services.zram.swap.enable = lib.mkDefault true;
}
