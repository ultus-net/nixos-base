# System services configuration module
# Desktop environment agnostic services
{ config, pkgs, lib, ... }:

{
  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; # Set to false for key-only auth
    };
  };

  # Enable CUPS for printing (optional)
  # services.printing.enable = true;

  # Enable sound with PipeWire (modern alternative to PulseAudio)
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # Enable if you need JACK support
  };

  # Enable fwupd for firmware updates
  services.fwupd.enable = true;

  # Enable automatic timezone detection (requires NetworkManager)
  services.automatic-timezoned.enable = false; # Set to true if desired

  # Enable locate database for fast file searching
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "hourly";
    localuser = null;
  };

  # Enable thermald for Intel CPU thermal management (Intel CPUs only)
  # services.thermald.enable = true;

  # Enable TLP for laptop power management (laptops only)
  # services.tlp.enable = true;

  # Enable Docker (optional)
  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = true;
  # };

  # Enable Podman as Docker alternative (optional)
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  # Enable libvirtd for QEMU/KVM virtualization (optional)
  # virtualisation.libvirtd.enable = true;

  # Enable Avahi for local network service discovery (optional)
  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;
  #   publish = {
  #     enable = true;
  #     addresses = true;
  #     domain = true;
  #     hinfo = true;
  #     userServices = true;
  #     workstation = true;
  #   };
  # };
}
