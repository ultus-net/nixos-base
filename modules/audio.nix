{ config, pkgs, lib, ... }:
{
  # PipeWire + WirePlumber with rtkit for low-latency
  security.rtkit.enable = true;
  sound.enable = false;            # disable legacy ALSA sound service
  hardware.pulseaudio.enable = false; # disable legacy PulseAudio service

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
