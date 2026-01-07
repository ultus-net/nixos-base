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
      eval "$(starship init bash)"
      eval "$(zoxide init bash)"
    '';
  };

  programs.starship = {
    enable = true;
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

  # VS Code managed by Home Manager (unfree). Swap to pkgs.vscodium if you
  # prefer the FOSS build.
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # Allow VSCode to manage its own extensions and settings
    mutableExtensionsDir = true;

    profiles.default = {
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        # Language support
        ms-python.python
        ms-python.vscode-pylance
        rust-lang.rust-analyzer
        golang.go

        # Formatters & Linters
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint

        # Git
        github.vscode-pull-request-github
        eamodio.gitlens

        # Nix
        bbenoist.nix
        jnoortheen.nix-ide
      ];

      # Removed userSettings to allow VS Code to manage its own settings
      # userSettings = {};
    };
  };

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
    foot           # Wayland terminal (default for COSMIC)
    kitty          # Alternative terminal

    # COSMIC-friendly GUI apps
    firefox        # Firefox (Wayland by default on COSMIC)
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
            model: "pc104",
            layout: "us",
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
            "Dock",
        ]
      '';
      force = true;
    };
  };
}

