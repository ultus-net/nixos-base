{ config, pkgs, lib, ... }:
{
  # NVIDIA proprietary driver configuration module
  # This module configures the proprietary NVIDIA driver and related settings
  # for optimal performance and stability on NVIDIA GPUs.

  # Use the proprietary NVIDIA driver instead of nouveau
  services.xserver.videoDrivers = [ "nvidia" ];

  # Blacklist the nouveau driver to prevent conflicts
  boot.blacklistedKernelModules = [ "nouveau" ];

  # NVIDIA-specific hardware configuration
  hardware.nvidia = {
    # Enable modesetting support (required for Wayland)
    modesetting.enable = true;

    # Use the production driver branch (recommended for most users)
    # For older GPUs, you may need to use the legacy drivers:
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enable the NVIDIA settings menu accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Power management options (can help with stability)
    powerManagement = {
      # Enabling this can help with graphical corruption or GPU
      # crashes after suspend/resume (per NixOS NVIDIA docs).
      enable = true;
      # Enable this for laptop or hybrid systems if you want
      # fine-grained power management of PRIME offload:
      # finegrained = true;
    };

    # Use the open-source NVIDIA kernel module (recommended for
    # Turing and newer GPUs, like your RTX 3070).
    open = true;

    # PRIME configuration for hybrid graphics (NVIDIA + AMD iGPU)
    # Sync mode keeps NVIDIA as primary GPU for best performance
    prime = {
      sync.enable = true;
      
      # Bus IDs - MANDATORY for PRIME to work
      # NVIDIA RTX 3070 is at 01:00.0 -> PCI:1:0:0
      nvidiaBusId = "PCI:1:0:0";
      
      # AMD Raphael iGPU is at 13:00.0 -> PCI:19:0:0 (0x13 = 19 in decimal)
      amdgpuBusId = "PCI:19:0:0";
    };
  };

  # Ensure OpenGL/graphics support is enabled
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for 32-bit applications like Steam
  };

  # Add NVIDIA packages to the system environment
  environment.systemPackages = with pkgs; [
    # NVIDIA management tools
    nvtopPackages.nvidia  # GPU monitoring tool
  ];
}
