{ config, pkgs, lib, ... }:
let
  cfg = config.virtualization;
in {
  options.virtualization = {
    enable = lib.mkEnableOption "Enable virtualization tools (KVM/libvirt)";
  };

  config = lib.mkIf cfg.enable {
    # Enable libvirt for KVM/QEMU virtualization
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;  # TPM emulation
      };
    };

    # Enable virt-manager GUI
    programs.virt-manager.enable = true;

    # Useful virtualization packages
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu
      OVMF
      libguestfs  # VM disk image tools
      libvirt
    ];

    # Enable dnsmasq for VM networking
    virtualisation.libvirtd.allowedBridges = [
      "virbr0"
    ];
  };
}
