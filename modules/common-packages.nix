{ config, pkgs, lib, ... }:
let
  cfg = config.commonPackages;
in {
  # Options for the common-packages module: an enable toggle and a list of
  # extra package values from `pkgs` to include in the system packages.
  options.commonPackages = {
    enable = lib.mkEnableOption "Enable a small set of desktop-agnostic common packages";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages (package values from pkgs) to include in system-wide packages.";
    };
  };

  # When enabled, compose the systemPackages list from any user-provided
  # packages plus a small pre-curated set of useful CLI tools and helpers.
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; (cfg.packages or []) ++ [
      # System monitoring
      htop
      btop
      bottom       # Alternative system monitor
      fastfetch    # System information
      
      # Terminal multiplexer & utilities
      tmux
      
      # Disk tools
      ncdu         # NCurses disk usage analyzer
      
      # Archive & compression (basic formats)
      unzip zip
      gzip bzip2 xz
      p7zip
      
      # Network & system tools
      rsync
      openssh
      curl wget
      httpie       # Better curl for APIs
      
      # Debugging & inspection
      lsof
      strace
      file
      
      # Version control
      git gh
      git-lfs      # Large file support (moved from development.nix for consistency)
      
      # Modern CLI replacements
      ripgrep      # Better grep
      fd           # Better find
      sd           # Better sed
      eza          # Better ls
      bat          # Better cat
      delta        # Better diff
      
      # Data processing
      jq yq        # JSON/YAML processors
      
      # Task runner
      just
      
      # Editor & shell
      neovim
      starship
      
      # Development helpers
      direnv nix-direnv
      hyperfine    # Benchmarking
      
      # Security
      age
      gnupg
      
      # Clipboard (Wayland)
      wl-clipboard
      
      # Enhanced CLI Tools
      fzf          # Fuzzy finder (essential for productivity)
      zoxide       # Smarter cd command
      tree         # Directory tree viewer
      tealdeer     # tldr pages (quick command help)
      trash-cli    # Safe rm alternative (moves to trash)
      glow         # Markdown renderer for terminal
      
      # Apps
      google-chrome
      spotify
    ];
  };
}
