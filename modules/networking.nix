{ config, pkgs, lib, ... }:
{
  # Networking defaults: enable NetworkManager and secure SSH defaults.

  networking.networkmanager.enable = true; # user-friendly network manager

  # SSH server: enabled by default for remote administration/testing.
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false; # disable password auth (use keys)
    PermitRootLogin = "no";        # disallow direct root SSH logins
  };
}
