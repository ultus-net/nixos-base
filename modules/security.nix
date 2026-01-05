{ config, pkgs, lib, ... }:
{
  # Basic security/QoL defaults
  services.fprintd.enable = true; # fingerprint auth if hardware supports it

  # Avahi/mDNS for local discovery (AirPrint, etc.)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # SSH agent for user sessions
  programs.ssh.startAgent = true;

  # Keep firewall enabled, no extra open ports by default
  networking.firewall.enable = true;
}
