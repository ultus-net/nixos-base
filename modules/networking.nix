{ config, pkgs, lib, ... }:
{
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
}
