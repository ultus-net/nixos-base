{ config, pkgs, lib, ... }:
{
  # Virtualization helpers: enable Podman (with Docker compatibility) and
  # libvirt for full virtualization. Brief comments describe each setting.
  virtualisation = {
    podman.enable = true;         # enable podman container runtime
    podman.dockerCompat = true;   # provide docker-compatible CLI shims
    libvirtd.enable = true;       # enable libvirt daemon for VMs
  };

  # Add the example user to the libvirtd group so they can manage VMs.
  users.groups.libvirtd.members = [ "csh" ];
}
