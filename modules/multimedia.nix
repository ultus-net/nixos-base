{ config, pkgs, lib, ... }:
let
  cfg = config.multimedia;
in {
  options.multimedia = {
    enable = lib.mkEnableOption "Enable multimedia tools and codecs (opt-in)";
    
    enableVideoEditing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install video editing tools (kdenlive, blender)";
    };
    
    enableAudioProduction = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install audio production tools (audacity, ardour)";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional multimedia packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Media Players
      vlc
      mpv
      
      # Image Viewers & Editors
      feh        # Lightweight image viewer
      imv        # Wayland image viewer
      gimp       # Image editor
      imagemagick # CLI image manipulation
      
      # Video Tools
      ffmpeg     # Video/audio processing
      yt-dlp     # YouTube downloader
      
      # Screenshot & Recording (desktop-agnostic)
      grim       # Wayland screenshot
      slurp      # Wayland region selector
      flameshot  # X11/Wayland screenshot tool
      peek       # GIF recorder
      obs-studio # Screen recording/streaming
      
    ] ++ cfg.extraPackages
      ++ lib.optionals cfg.enableVideoEditing [
      kdenlive
      blender
      shotcut
    ] ++ lib.optionals cfg.enableAudioProduction [
      audacity
      ardour
    ];
  };
}
