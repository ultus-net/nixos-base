{ config, pkgs, lib, ... }:
{
  # Home Manager manages user-level configuration files and packages.
  # This is a template configuration - copy and modify for your own user.

  # IMPORTANT: When using with NixOS, set this in your machine config instead:
  # home-manager.users.yourusername = import ./home/yourusername.nix;

  # For standalone (non-NixOS) usage:
  # home-manager switch --flake .#yourusername@x86_64-linux

  home.stateVersion = "24.11";

  # Home Manager should manage itself.
  programs.home-manager.enable = true;

  # Shell configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };

    initExtra = ''
      # Custom bash configuration
      export EDITOR="nvim"
      eval "$(zoxide init bash)"

      # Run fastfetch with default logo on interactive shells if available
      if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
      fi
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Preserve legacy dotdir behavior to avoid stateVersion warnings
    dotDir = config.home.homeDirectory;

    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };

    initExtra = ''
      export EDITOR="nvim"
      eval "$(zoxide init zsh)"

      # Run fastfetch on interactive shells if available
      if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      command_timeout = 1200;

      # Custom prompt elements
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "Hunter";
      # IMPORTANT: Change this to your actual email before committing code!
      user.email = "user@example.com";  # TODO: Update this

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";

      # Better diffs
      diff.algorithm = "histogram";

      # Reuse recorded resolutions
      rerere.enabled = true;
    };

    ignores = [
      "*~"
      "*.swp"
      ".DS_Store"
      ".direnv/"
      "result"
      "result-*"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # COSMIC-specific environment variables
  # Temporarily disabled to allow manual COSMIC configuration
  # These will be re-enabled after extracting your custom settings
  # home.sessionVariables = {
  #   # Use Wayland for applications that support it
  #   MOZ_ENABLE_WAYLAND = "1";
  #   NIXOS_OZONE_WL = "1";  # Chromium/Electron apps
  #   QT_QPA_PLATFORM = "wayland";
  #   SDL_VIDEODRIVER = "wayland";
  #   _JAVA_AWT_WM_NONREPARENTING = "1";  # Java app tiling fix
  #
  #   # COSMIC-specific
  #   XDG_CURRENT_DESKTOP = "COSMIC";
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-lspconfig
      nvim-treesitter
      telescope-nvim
      vim-surround
      vim-commentary
    ];

    extraConfig = ''
      set number
      set relativenumber
      set ignorecase smartcase
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set clipboard=unnamedplus
    '';
  };

  # VS Code installation (unfree). Swap to pkgs.vscodium if you
  # prefer the FOSS build.
  # VS Code will manage its own extensions and settings.

  # fzf configuration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # zoxide (smarter cd)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  # eza (better ls) - configured via aliases above

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # CLI utilities (beyond what's in common-packages)
    # Add user-specific tools here

    # Terminal emulators
    kitty          # Alternative terminal

    # COSMIC-friendly GUI apps
    firefox        # Firefox (Wayland by default on COSMIC)
    vscode         # VS Code editor (manages own extensions/settings)
    nodePackages_latest.typescript-language-server
    nodePackages_latest.vscode-langservers-extracted
    marksman       # Markdown LSP
    nil            # Nix LSP

    # Additional development tools
    lazydocker     # Docker TUI
    k9s            # Kubernetes TUI (if you use k8s)
  ];

  # XDG configuration
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  # COSMIC Desktop Environment Configuration
  # These settings match your customized COSMIC configuration
  xdg.configFile = {
    # Compositor settings
    "cosmic/com.system76.CosmicComp/v1/xkb_config" = {
      text = ''
        (
            rules: "",
            model: "pc105",
            layout: "nz",
            variant: "",
            options: Some("terminate:ctrl_alt_bksp"),
            repeat_delay: 600,
            repeat_rate: 25,
        )
      '';
      force = true;
    };

    "cosmic/com.system76.CosmicComp/v1/autotile" = {
      text = "true";
      force = true;
    };

    "cosmic/com.system76.CosmicComp/v1/autotile_behavior" = {
      text = "PerWorkspace";
      force = true;
    };

    "cosmic/com.system76.CosmicComp/v1/focus_follows_cursor" = {
      text = "true";
      force = true;
    };

    "cosmic/com.system76.CosmicComp/v1/active_hint" = {
      text = "false";
      force = true;
    };

    # Theme settings - Dark mode
    "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" = {
      text = "true";
      force = true;
    };

    # Panel configuration
    "cosmic/com.system76.CosmicPanel/v1/entries" = {
      text = ''
        [
          "Panel",
          "com.system76.CosmicAppletMedia"
        ]
      '';
      force = true;
    };

    # Ensure the panel plugins place the media controls in the center
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center" = {
      text = ''
        Some([
            "com.system76.CosmicAppletTime",
            "com.system76.CosmicAppletMedia",
        ])
      '';
      force = true;
    };

    # Remove the StatusArea (system tray) to hide legacy tray icons like Spotify,
    # but keep other individual applets (network, battery, notifications, etc.).
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings" = {
      text = ''
        Some(([
            "com.system76.CosmicAppletWorkspaces",
        ], [
            "com.system76.CosmicAppletTiling",
            "com.system76.CosmicAppletAudio",
            "com.system76.CosmicAppletBluetooth",
            "com.system76.CosmicAppletNetwork",
            "com.system76.CosmicAppletBattery",
            "com.system76.CosmicAppletNotifications",
            "com.system76.CosmicAppletPower",
        ]))
      '';
      force = true;
    };
    # Wallpaper configuration for all outputs (global default)
    # Rotates through official NixOS wallpapers from nixos-artwork collection
    "cosmic/com.system76.CosmicBackground/v1/default" = {
      text = ''
        (
            output: "*",
            source: Directory("${config.home.homeDirectory}/.wallpapers"),
            filter_by_theme: false,
            rotation_frequency: 300,
            filter_method: Lanczos,
            scaling_mode: Zoom,
            sampling_method: Alphanumeric,
        )
      '';
      force = true;
    };

    "cosmic/com.system76.CosmicBackground/v1/output.HDMI-A-4" = {
      text = ''
(
    output: "HDMI-A-4",
    source: Path("${config.home.homeDirectory}/.wallpapers/nix-d-nord-1080p.png"),
    filter_by_theme: false,
    rotation_frequency: 300,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
      '';
      force = true;
    };

    # Panel dock specifics (sourced from current desktop)
    "cosmic/com.system76.CosmicPanel.Dock/v1/size" = {
      text = "M";
      force = true;
    };

    "cosmic/com.system76.CosmicPanel.Dock/v1/anchor" = {
      text = "Bottom";
      force = true;
    };

    "cosmic/com.system76.CosmicPanel.Dock/v1/autohide" = {
      text = ''
Some((
    wait_time: 1000,
    transition_time: 200,
    handle_size: 4,
    unhide_delay: 200,
))
      '';
      force = true;
    };

    "cosmic/com.system76.CosmicPanel.Dock/v1/opacity" = {
      text = "0.5";
      force = true;
    };

    # Interface density and applet time settings
    "cosmic/com.system76.CosmicTk/v1/interface_density" = {
      text = "Compact";
      force = true;
    };

    "cosmic/com.system76.CosmicAppletTime/v1/show_date_in_top_panel" = {
      text = "false";
      force = true;
    };

    "cosmic/com.system76.CosmicAppletTime/v1/military_time" = {
      text = "false";
      force = true;
    };

  };

  # Symlink official NixOS wallpapers for desktop environment rotation
  # Complete collection of all official and community NixOS wallpapers
  
  # Binary series
  home.file.".wallpapers/binary-black.png".source = "${pkgs.nixos-artwork.wallpapers.binary-black}/share/backgrounds/nixos/nix-wallpaper-binary-black.png";
  home.file.".wallpapers/binary-blue.png".source = "${pkgs.nixos-artwork.wallpapers.binary-blue}/share/backgrounds/nixos/nix-wallpaper-binary-blue.png";
  home.file.".wallpapers/binary-red.png".source = "${pkgs.nixos-artwork.wallpapers.binary-red}/share/backgrounds/nixos/nix-wallpaper-binary-red.png";
  home.file.".wallpapers/binary-white.png".source = "${pkgs.nixos-artwork.wallpapers.binary-white}/share/backgrounds/nixos/nix-wallpaper-binary-white.png";
  
  # Catppuccin series
  
  # Nineish series (retro style)
  home.file.".wallpapers/nineish.png".source = "${pkgs.nixos-artwork.wallpapers.nineish}/share/backgrounds/nixos/nix-wallpaper-nineish.png";
  home.file.".wallpapers/nineish-dark-gray.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
  home.file.".wallpapers/nineish-solarized-dark.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-solarized-dark}/share/backgrounds/nixos/nix-wallpaper-nineish-solarized-dark.png";
  home.file.".wallpapers/nineish-solarized-light.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-solarized-light}/share/backgrounds/nixos/nix-wallpaper-nineish-solarized-light.png";
  home.file.".wallpapers/nineish-catppuccin-frappe.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-frappe}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-frappe.png";
  home.file.".wallpapers/nineish-catppuccin-frappe-alt.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-frappe-alt}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-frappe-alt.png";
  home.file.".wallpapers/nineish-catppuccin-latte.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-latte}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-latte.png";
  home.file.".wallpapers/nineish-catppuccin-latte-alt.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-latte-alt}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-latte-alt.png";
  home.file.".wallpapers/nineish-catppuccin-macchiato.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-macchiato}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-macchiato.png";
  home.file.".wallpapers/nineish-catppuccin-macchiato-alt.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-macchiato-alt}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-macchiato-alt.png";
  home.file.".wallpapers/nineish-catppuccin-mocha.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-mocha.png";
  home.file.".wallpapers/nineish-catppuccin-mocha-alt.png".source = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha-alt}/share/backgrounds/nixos/nix-wallpaper-nineish-catppuccin-mocha-alt.png";
  
  # Classic NixOS wallpapers
  home.file.".wallpapers/simple-blue.png".source = "${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
  home.file.".wallpapers/simple-dark-gray.png".source = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png";
  home.file.".wallpapers/simple-light-gray.png".source = "${pkgs.nixos-artwork.wallpapers.simple-light-gray}/share/backgrounds/nixos/nix-wallpaper-simple-light-gray.png";
  home.file.".wallpapers/simple-red.png".source = "${pkgs.nixos-artwork.wallpapers.simple-red}/share/backgrounds/nixos/nix-wallpaper-simple-red.png";
  home.file.".wallpapers/mosaic-blue.png".source = "${pkgs.nixos-artwork.wallpapers.mosaic-blue}/share/backgrounds/nixos/nix-wallpaper-mosaic-blue.png";
  home.file.".wallpapers/stripes.png".source = "${pkgs.nixos-artwork.wallpapers.stripes}/share/backgrounds/nixos/nix-wallpaper-stripes.png";
  home.file.".wallpapers/stripes-logo.png".source = "${pkgs.nixos-artwork.wallpapers.stripes-logo}/share/backgrounds/nixos/nix-wallpaper-stripes-logo.png";
  
  # 3D renders
  home.file.".wallpapers/dracula.png".source = "${pkgs.nixos-artwork.wallpapers.dracula}/share/backgrounds/nixos/nix-wallpaper-dracula.png";
  home.file.".wallpapers/gear.png".source = "${pkgs.nixos-artwork.wallpapers.gear}/share/backgrounds/nixos/nix-wallpaper-gear.png";
  home.file.".wallpapers/moonscape.png".source = "${pkgs.nixos-artwork.wallpapers.moonscape}/share/backgrounds/nixos/nix-wallpaper-moonscape.png";
  home.file.".wallpapers/recursive.png".source = "${pkgs.nixos-artwork.wallpapers.recursive}/share/backgrounds/nixos/nix-wallpaper-recursive.png";
  home.file.".wallpapers/waterfall.png".source = "${pkgs.nixos-artwork.wallpapers.waterfall}/share/backgrounds/nixos/nix-wallpaper-waterfall.png";
  home.file.".wallpapers/watersplash.png".source = "${pkgs.nixos-artwork.wallpapers.watersplash}/share/backgrounds/nixos/nix-wallpaper-watersplash.png";
  
  # Other wallpapers
  home.file.".wallpapers/gnome-dark.png".source = "${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png";
  home.file.".wallpapers/gradient-grey.png".source = "${pkgs.nixos-artwork.wallpapers.gradient-grey}/share/backgrounds/nixos/nix-wallpaper-gradient-grey.png";

  # Custom repo wallpaper (zoomed-out tiled variant)
  home.file.".wallpapers/nix-d-nord-1080p.png".source = "${./../wallpapers/nix-d-nord-1080p.png}";

  # Preserve monitor layout from current setup
  home.file.".config/monitors.xml".text = ''
<monitors version="2">
  <configuration>
    <layoutmode>physical</layoutmode>
    <logicalmonitor>
      <x>1920</x>
      <y>0</y>
      <scale>1</scale>
      <monitor>
        <monitorspec>
          <connector>HDMI-3</connector>
          <vendor>AUS</vendor>
          <product>VG279QR</product>
          <serial>LBLMQS157992</serial>
        </monitorspec>
        <mode>
          <width>1920</width>
          <height>1080</height>
          <rate>60.000</rate>
        </mode>
      </monitor>
    </logicalmonitor>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>HDMI-4</connector>
          <vendor>AUS</vendor>
          <product>VG279QR</product>
          <serial>LALMQS240240</serial>
        </monitorspec>
        <mode>
          <width>1920</width>
          <height>1080</height>
          <rate>60.000</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
'';

  # Activation script to ensure COSMIC picks up configuration changes
  home.activation.cosmicReload = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Restart COSMIC compositor to pick up super key and other compositor settings
    if pgrep -x cosmic-comp > /dev/null; then
      $DRY_RUN_CMD pkill -x cosmic-comp || true
    fi
    
    # Restart COSMIC background process to pick up new wallpaper
    if pgrep -x cosmic-bg > /dev/null; then
      $DRY_RUN_CMD pkill -x cosmic-bg || true
    fi
  '';
}
