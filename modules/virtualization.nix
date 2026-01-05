{ config, pkgs, lib, ... }:
{
  virtualisation = {
    podman.enable = true;
    podman.dockerCompat = true;
    libvirtd.enable = true;
  };

  users.groups.libvirtd.members = [ "csh" ];
}
