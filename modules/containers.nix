{ config, pkgs, lib, ... }:
let
  cfg = config.machines.containers;
in {
  options.machines.containers = {
    enable = lib.mkEnableOption "Enable container and virtualization tools (opt-in)";
    
    enableDistrobox = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install distrobox for running other Linux distributions in containers";
    };
    
    enableKubernetes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Kubernetes tools (kubectl, k9s, helm)";
    };
    
    enableDockerCompat = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker CLI compatibility for Podman";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional container-related packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Podman (Docker alternative)
    virtualisation.podman = {
      enable = true;
      dockerCompat = cfg.enableDockerCompat;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Enable container networking
    virtualisation.containers.enable = true;
    
    environment.systemPackages = with pkgs; [
      # Core container tools
      podman
      podman-compose
      buildah      # Container image builder
      skopeo       # Container image inspector
      
    ] ++ lib.optionals cfg.enableDistrobox [
      distrobox
      boxbuddy     # Distrobox GUI
    ] ++ lib.optionals cfg.enableKubernetes [
      kubectl
      k9s          # Kubernetes TUI
      helm         # Kubernetes package manager
      kubectx      # Switch between clusters
      kustomize    # Kubernetes config management
    ] ++ cfg.extraPackages;
  };
}
