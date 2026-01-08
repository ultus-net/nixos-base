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
    
    enableDockerCompose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install docker-compose for managing multi-container apps";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional container-related packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Docker
    virtualisation.docker = {
      enable = true;
    };
    
    # Enable container networking
    virtualisation.containers.enable = true;
    
    environment.systemPackages = with pkgs; [
      # Core container tools
      docker
    ] ++ lib.optionals cfg.enableDockerCompose [
      docker-compose
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
