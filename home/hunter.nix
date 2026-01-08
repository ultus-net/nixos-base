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
            source: Path("${config.home.homeDirectory}/.wallpapers/nixos-honeycomb-nixos-brand.png"),
            filter_by_theme: false,
            rotation_frequency: 0,
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
    source: Path("${config.home.homeDirectory}/.wallpapers/nixos-honeycomb-nixos-brand.png"),
    filter_by_theme: false,
    rotation_frequency: 0,
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

  # Use local wallpapers from the repo `assets/wallpapers` instead of
  # the nixos-artwork package collection. Add files here as needed.

  home.file.".wallpapers/nix-d-nord.png".source = ../assets/wallpapers/nix-d-nord-1080p.png;
  home.file.".wallpapers/nixos-honeycomb-nord-dark.png".source = ../assets/wallpapers/nixos-honeycomb-nord-dark.png;
  home.file.".wallpapers/nixos-honeycomb-nord-light.png".source = ../assets/wallpapers/nixos-honeycomb-nord-light.png;
  home.file.".wallpapers/nixos-honeycomb-dracula.png".source = ../assets/wallpapers/nixos-honeycomb-dracula.png;
  home.file.".wallpapers/nixos-honeycomb-gruvbox-dark.png".source = ../assets/wallpapers/nixos-honeycomb-gruvbox-dark.png;
  home.file.".wallpapers/nixos-honeycomb-nixos-brand.png".source = ../assets/wallpapers/nixos-honeycomb-nixos-brand.png;
  home.file.".wallpapers/nixos-honeycomb-nord-dark-zoomed.png".source = ../assets/wallpapers/nixos-honeycomb-nord-dark-zoomed.png;
  home.file.".wallpapers/nixos-honeycomb-nord-red.png".source = ../assets/wallpapers/nixos-honeycomb-nord-red.png;
  home.file.".wallpapers/nixos-honeycomb-nord-frost.png".source = ../assets/wallpapers/nixos-honeycomb-nord-frost.png;
  home.file.".wallpapers/nix-d-nord.svg".source = ../assets/wallpapers/nix-d-nord.svg;
  home.file.".wallpapers/nixos-logo.png".source = ../assets/wallpapers/nixos-logo.png;

  # Custom repo wallpaper (zoomed-out tiled variant)
  home.file.".wallpapers/nix-d-nord-1080p.png".source = ../assets/wallpapers/nix-d-nord-1080p.png;

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
