{ config, pkgs, lib, ... }:
{
  # Security module: small, pragmatic defaults for desktop usage; each line
  # explains the reason for the chosen default.

  # Enable fingerprintd service for fingerprint authentication when hardware
  # and PAM integration are present.
  services.fprintd.enable = true;

  # Avahi provides mDNS/zeroconf for local network discovery (useful for
  # AirPrint, printers, and other services). `openFirewall` relaxes firewall
  # rules for local service discovery when enabled.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Start an SSH agent in user sessions to hold private keys for authentication.
  programs.ssh.startAgent = true;

  # Keep the firewall enabled by default and avoid opening extra ports here.
  networking.firewall.enable = true;
}
