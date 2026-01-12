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
      enable = lib.mkDefault false;
      # Enable this for laptop or hybrid systems:
      # finegrained = false;
    };

    # Open-source kernel modules (experimental, not recommended for gaming)
    open = false;
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
