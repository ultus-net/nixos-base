{
  description = "Modular NixOS flake with 9 desktop environments, Home Manager, and developer tools";

  inputs = {
    # Pin nixpkgs to nixpkgs-unstable for the latest packages and fixes
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Stable channel used for a few specific packages (e.g. google-chrome)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, flake-utils, home-manager, devshell }:
    let
      # Standalone home-manager configurations (not tied to NixOS)
      mkHomeConfiguration = system: username: homeDirectory: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        
        modules = [
          ./home/${username}.nix
          {
            home = {
              inherit username homeDirectory;
              stateVersion = "24.11";
            };
          }
        ];
      };
    in
    (flake-utils.lib.eachDefaultSystem (system:
      let
        # Stable package set for a few hand-picked packages
        stablePkgs = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # for fonts, VS Code, etc.
          };
          overlays = [ 
            devshell.overlays.default 
            # Fix for Steam apt installation bug in nixpkgs commit 16c7794d
            (final: prev: {
              steam-unwrapped = prev.steam-unwrapped.overrideAttrs (oldAttrs: {
                postPatch = (oldAttrs.postPatch or "") + ''
                  # Skip the apt source installation that fails in Nix sandbox
                  sed -i '/if \[ -d \/etc\/apt \]; then/,/fi/d' Makefile
                '';
              });
            })

            # Prefer a stable google-chrome build from nixos-24.05
            (final: prev: {
              google-chrome = stablePkgs.google-chrome;
            })
          ];
        };
      in {
        # A developer shell with common tools similar to Universal Blue QoL
        devShells.default = pkgs.devshell.mkShell {
          name = "cosmic-workstation";
          packages = with pkgs; [
            # shells & core
            bashInteractive
            gnupg
            git
            gh
            direnv
            nix-direnv
            jq yq
            ripgrep fd
            sd
            eza
            delta
            starship

            # networking & ops
            curl wget
            httpie
            # iproute2 is Linux-specific; include only on linux systems
            # (avoid evaluating this package on unsupported host platforms)
          ] ++ pkgs.lib.optionals (builtins.match ".*-linux" system != null) [ iproute2 ] ++ [

            # editors
            neovim

            # language toolchains (lightweight)
            python3
            nodejs_22
            pnpm
            bun
            go
            rustup

            # containers
            docker
            docker-compose

            # formatters/linters
            shfmt shellcheck
            black ruff
            prettier
            eslint_d
            stylua

            # build tools
            cmake
            pkg-config
            just
          ];
          env = [
            {
              name = "DEVSHELL_ENABLE_DIRenv";
              value = "1";
            }
          ];
          commands = [
            {
              name = "setup-dev";
              help = "Initialize direnv + allow, and install rust toolchain";
              command = ''
                if [ -f .envrc ]; then echo "Found .envrc"; else echo "use nix" > .envrc; fi
                direnv allow . || true
                rustup default stable || true
              '';
            }
          ];
        };

        packages.default = pkgs.writeShellApplication {
          name = "cosmic-qol";
          runtimeInputs = with pkgs; [ eza ripgrep fd starship neovim ];
          text = ''
            echo "COSMIC QoL helpers installed via Nix"
          '';
        };

        # OCI / Docker image containing a lightweight dev environment
        # Use `copyToRoot` with `buildEnv` instead of the deprecated `contents`.
        packages.cosmicImage = pkgs.dockerTools.buildImage {
          name = "cosmic-workstation";
          copyToRoot = pkgs.buildEnv {
            name = "cosmic-workstation-root";
              paths = with pkgs; [
              bashInteractive
              git
              gh
              direnv
              nix-direnv
              jq
              yq
              ripgrep
              fd
              sd
              eza
              delta
              starship
              neovim
              python3
              nodejs_22
              pnpm
              go
              rustup
              docker
              docker-compose
              cmake
              pkg-config
              just
            ];
          };
          config = {
            Cmd = [ "/bin/bash" ];
          };
        };

        # KDE-specific OCI image (lightweight developer container with KDE tools)
        packages.kdeImage = pkgs.dockerTools.buildImage {
          name = "kde-dev";
          copyToRoot = pkgs.buildEnv {
            name = "kde-dev-root";
            paths = with pkgs; [
              bashInteractive
              git
              gh
              direnv
              jq
              ripgrep
              eza
              neovim
              python3
              nodejs_22
              pnpm
              go
              rustup
              cmake
              pkg-config
              just
              # KDE specific tooling (lightweight)
              # (keep this list minimal and avoid referencing attributes that may
              # not exist in all nixpkgs snapshots)
            ];
          };
          config = { Cmd = [ "/bin/bash" ]; };
        };

        # Home Manager module for common QoL on COSMIC
        homeManagerModules.default = { config, pkgs, lib, ... }:
          let cfg = config.cosmicDev;
          in {
            options.cosmicDev.enable = lib.mkEnableOption "Enable developer QoL config for COSMIC";
            config = lib.mkIf cfg.enable {
              programs.home-manager.enable = true;

              # Shell basics
              programs.zsh.enable = false;
              programs.bash = {
                enable = true;
                enableCompletion = true;
                bashrcExtra = ''
                  eval "$(starship init bash)"
                '';
              };

              programs.starship = {
                enable = true;
                settings = {
                  add_newline = false;
                  command_timeout = 1200;
                };
              };

              # Direnv
              programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
              };

              # Git
              programs.git = {
                enable = true;
                userName = "${config.home.username}";
                userEmail = "${config.home.username}@local";
                extraConfig = {
                  init.defaultBranch = "main";
                  pull.rebase = true;
                };
              };

              # Delta (git pager) as a separate program module
              programs.delta = {
                enable = true;
              };

              # Neovim basic setup
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
                ];
                extraConfig = ''
                  set number
                  set relativenumber
                  set ignorecase smartcase
                '';
              };

              # Common packages
              home.packages = with pkgs; [
                # fonts & emoji
                (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
                noto-fonts-emoji

                # tools
                eza ripgrep fd jq yq delta sd
                just
                gnupg
                gh
                bat
                hyperfine

                # language servers
                nodePackages_latest.typescript-language-server
                nodePackages_latest.vscode-langservers-extracted
                marksman

                # cosmic-friendly apps (installed via nix when possible)
                # Note: COSMIC is Wayland-first; these are Wayland-friendly.
              ];

              fonts.fontconfig.enable = true;

              # VSCode via Home Manager (unfree)
              programs.vscode = {
                enable = true;
                enableExtensionUpdateCheck = false;
                package = pkgs.vscode;
                extensions = with pkgs.vscode-extensions; [
                  ms-vscode.cpptools
                  ms-python.python
                  ms-python.vscode-pylance
                  rust-lang.rust-analyzer
                  esbenp.prettier-vscode
                  dbaeumer.vscode-eslint
                  github.vscode-pull-request-github
                ];
                userSettings = {
                  "editor.fontFamily" = "JetBrainsMono Nerd Font";
                  "editor.fontLigatures" = true;
                  "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
                  "files.trimTrailingWhitespace" = true;
                  "editor.formatOnSave" = true;
                };
              };

              # COSMIC/Wayland quality-of-life
              xdg.mime.enable = true;
              xdg.enable = true;
              xdg.userDirs.enable = true;
            };
          };

        # A sample Home Manager configuration exposing the module
        # Users can link this file or copy content.
      })
    ) // {
      # NixOS system configurations
      nixosConfigurations = let
          system = "x86_64-linux";
          mkSystem = profile: nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inputs = self.inputs; };
            modules = [ profile ];
          };
        in {
          # Headless/Server base configuration (no desktop environment)
          base-server = mkSystem ./profiles/base.nix;
          
          # Real machine configurations
          tower = mkSystem ./machines/tower.nix;
          
          # Real COSMIC desktop (System76) - Wayland, Rust-based
          cosmic-workstation = mkSystem ./profiles/cosmic.nix;
          
          # GNOME - Modern GNOME Shell desktop
          gnome-workstation = mkSystem ./profiles/gnome.nix;
          
          # KDE Plasma 6 - Feature-rich Qt desktop
          kde-workstation = mkSystem ./profiles/kde.nix;
          
          # Cinnamon - Linux Mint's flagship desktop
          cinnamon-workstation = mkSystem ./profiles/cinnamon.nix;
          
          # XFCE - Lightweight, traditional desktop
          xfce-workstation = mkSystem ./profiles/xfce.nix;
        };

      # Out-of-system content like templates
      templates = {
        homeManager = {
          path = ./templates/home;
          description = "Example Home Manager config enabling COSMIC developer QoL";
        };
      };

      # Standalone Home Manager configurations (for non-NixOS systems)
      homeConfigurations = {
        # Example: hunter@x86_64-linux
        "hunter@x86_64-linux" = mkHomeConfiguration "x86_64-linux" "hunter" "/home/hunter";

        # Add more users as needed:
        # "youruser@x86_64-linux" = mkHomeConfiguration "x86_64-linux" "youruser" "/home/youruser";
        # "youruser@aarch64-linux" = mkHomeConfiguration "aarch64-linux" "youruser" "/home/youruser";
        # "youruser@x86_64-darwin" = mkHomeConfiguration "x86_64-darwin" "youruser" "/Users/youruser";
      };
    };
  }
