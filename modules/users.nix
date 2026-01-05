# User management configuration module
{ config, pkgs, lib, ... }:

{
  # Define a user account
  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS User";
    extraGroups = [ 
      "networkmanager" 
      "wheel"      # Enable sudo
      "video"      # Access to video devices
      "audio"      # Access to audio devices
      "input"      # Access to input devices
      "storage"    # Access to storage devices
    ];
    
    # Set default shell (optional)
    # shell = pkgs.zsh;
    
    # Initial password (change on first login!)
    # initialPassword = "changeme";
    
    # Or use hashedPassword generated with: mkpasswd -m sha-512
    # hashedPassword = "...";
  };

  # Enable sudo without password for wheel group (optional, less secure)
  # security.sudo.wheelNeedsPassword = false;

  # Default user shell
  users.defaultUserShell = pkgs.bash;

  # Root user configuration
  # users.users.root.hashedPassword = "...";
}
