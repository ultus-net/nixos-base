# System packages configuration module
# Desktop environment agnostic - includes essential CLI and system tools
{ config, pkgs, lib, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim
    wget
    curl
    git
    htop
    tree
    unzip
    zip
    gzip
    
    # Network tools
    nettools
    dnsutils
    inetutils
    traceroute
    
    # File management
    rsync
    rclone
    
    # Disk utilities
    parted
    gptfdisk
    
    # Process management
    killall
    pstree
    
    # System information
    lshw
    pciutils
    usbutils
    
    # Text processing
    ripgrep
    fd
    jq
    
    # Archive tools
    p7zip
    unrar
    
    # Build tools (useful for development)
    gcc
    gnumake
    pkg-config
    
    # Man pages
    man-pages
    man-pages-posix
  ];

  # Enable bash completion
  programs.bash.enableCompletion = true;

  # Environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Default shell aliases (optional)
  environment.shellAliases = {
    ll = "ls -lah";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
}
