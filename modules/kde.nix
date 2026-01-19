{ config, pkgs, lib, ... }:
let
  cfg = config.kde;

  # Conservative list of KDE/Plasma package attribute names we try to include
  # when present in pkgs. We filter by presence to avoid evaluation errors
  # across different nixpkgs versions.
  desiredAttrs = [ 
    "dolphin" "konsole" "okular" "kate" "kdeconnect"
    "spectacle" "ark" "gwenview" "plasma-browser-integration"
    "breeze-icons" "kwrite" "kcalc" "kcharselect"
    "kclock" "kcolorchooser" "ksystemlog" "kio-fuse"
  ];

  # Map available attribute names to actual package values.
  available = builtins.map (n: builtins.getAttr n pkgs.kdePackages)
    (builtins.filter (n: lib.hasAttr n pkgs.kdePackages) desiredAttrs);
in {
  options.kde = {
    enable = lib.mkEnableOption "Enable KDE Plasma (opt-in)";
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install when KDE is enabled.";
    };
    
    enableWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prefer Wayland session for Plasma.";
    };
    
    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "with pkgs.kdePackages; [ elisa kpat ]";
      description = "List of KDE Plasma packages to exclude from the default installation.";
    };

    enableXWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable XWayland so X11 apps can run under Plasma Wayland.";
    };

    useRootlessX11 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run SDDM's X11 session as the user (x11-user) instead of root when Wayland is disabled.";
    };

    sddmTheme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "breeze";
      description = "Optional SDDM theme name to apply (must be installed).";
    };

    enableKDEConnectFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for KDE Connect device discovery and file transfer.";
    };

    disableBaloo = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable the Baloo file indexer to save disk IO and background CPU.";
    };

    enableKWalletPAM = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Unlock KWallet automatically on login using PAM integration.";
    };

    enableBluetoothManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bluetooth support (recommended for KDE Connect and wireless peripherals).";
    };

    enablePlasmaVault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Plasma Vault for encrypted folders (requires cryfs or gocryptfs).";
    };

    screenLockerTimeout = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Minutes of inactivity before locking the screen (0 to disable).";
    };

    optimizeFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable font hinting and antialiasing for better text rendering.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the Plasma 6 desktop and SDDM display manager with optional Wayland.
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    
    # Configure SDDM and default session
    services.displayManager = {
      sddm = lib.mkMerge [
        {
          enable = true;
          wayland.enable = cfg.enableWayland;
          settings.General.DisplayServer =
            if cfg.enableWayland then "wayland"
            else if cfg.useRootlessX11 then "x11-user"
            else "x11";
        }
        (lib.optionalAttrs (cfg.sddmTheme != null) { theme = cfg.sddmTheme; })
      ];
      
      # Default to X11 session name if Wayland is not preferred
      defaultSession = lib.mkIf (!cfg.enableWayland) "plasmax11";
    };

    programs.xwayland.enable = cfg.enableXWayland;

    # Exclude unwanted packages
    environment.plasma6.excludePackages = cfg.excludePackages;

    # Install extra user-provided packages plus the conservative KDE list and optional Plasma Vault tools.
    environment.systemPackages = lib.unique (
      (cfg.extraPackages or []) 
      ++ available 
      ++ (with pkgs; [
        # Official NixOS wallpapers
        nixos-artwork.wallpapers.nineish-dark-gray
        nixos-artwork.wallpapers.simple-blue
        nixos-artwork.wallpapers.stripes-logo
        nixos-artwork.wallpapers.mosaic-blue
      ])
      ++ (lib.optionals cfg.enablePlasmaVault [
        pkgs.cryfs
        pkgs.gocryptfs
      ])
    );

    # Enable portals for sandboxed apps and correct file pickers on Wayland.
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
    };

    # Note: Baloo file indexing is controlled through Plasma System Settings,
    # not through NixOS configuration. The disableBaloo option is kept for
    # documentation but doesn't currently affect the system configuration.
    # To disable Baloo, go to: System Settings -> File Indexing -> Disable

    # KDE Connect works best with the discovery ports opened.
    networking.firewall = lib.mkMerge [
      {}
      (lib.optionalAttrs cfg.enableKDEConnectFirewall {
        allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
        allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
      })
    ];

    # KWallet PAM integration for automatic unlock on login
    security.pam.services = lib.mkIf cfg.enableKWalletPAM {
      sddm.enableKwallet = true;
      login.enableKwallet = true;
    };

    # Bluetooth support (recommended for KDE Connect and wireless devices)
    hardware.bluetooth = lib.mkIf cfg.enableBluetoothManager {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;  # Enable experimental features like battery reporting
        };
      };
    };

    # Font rendering optimization for KDE
    fonts.fontconfig = lib.mkIf cfg.optimizeFonts {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Hack" "Source Code Pro" ];
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };
      antialias = true;
    };

    # Screen locker configuration
    programs.kdeconnect.enable = cfg.enableKDEConnectFirewall;
  };
}
