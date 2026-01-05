# Networking configuration module
{ config, pkgs, lib, ... }:

{
  # Define hostname
  networking.hostName = "nixos-base"; # Change this to your desired hostname

  # Enable NetworkManager for easy network management
  networking.networkmanager.enable = true;

  # Alternative: Use systemd-networkd
  # networking.useNetworkd = true;
  # systemd.network.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    # allowPing = true;
  };

  # Enable IPv6
  networking.enableIPv6 = true;

  # DNS configuration (optional)
  # networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Proxy configuration (optional)
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
