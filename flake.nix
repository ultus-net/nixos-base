{
  description = "Full NixOS COSMIC developer workstation with QoL, Home Manager, and devshells";

  inputs = {
  # Pin nixpkgs to a specific commit for reproducibility. The commit hash
  # is taken from `flake.lock` (pinned to the current nixpkgs-unstable tip).
  nixpkgs.url = "github:NixOS/nixpkgs/16c7794d0a28b5a37904d55bcca36003b9109aaa";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # for fonts, VS Code, etc.
          };
          overlays = [ devshell.overlays.default ];
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
            iproute2

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
            podman
            podman-compose

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
              podman
              podman-compose
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

        # GNOME-specific OCI image
        packages.gnomeImage = pkgs.dockerTools.buildImage {
          name = "gnome-dev";
          copyToRoot = pkgs.buildEnv {
            name = "gnome-dev-root";
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
              # GNOME specific (example)
              # (left intentionally minimal to avoid depending on top-level 'gnome' attr)
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
                foot
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
      }) // {
        nixosConfigurations = {
          cosmic-workstation = let
            system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inputs = self.inputs; };
              modules = [
              ./profiles/cosmic.nix
            ];
          };

          # Expose GNOME workstation as a top-level nixosConfiguration so there
          # is only a single top-level flake providing desktop configurations.
          gnome-workstation = let
            system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inputs = self.inputs; };
            modules = [
              ./profiles/gnome.nix
            ];
          };

          # KDE workstation exposed at top-level like the others
          kde-workstation = let
            system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inputs = self.inputs; };
            modules = [
              ./profiles/kde.nix
            ];
          };
        };

        # Out-of-system content like templates
        templates = {
          homeManager = {
            path = ./templates/home;
            description = "Example Home Manager config enabling COSMIC developer QoL";
          };
        };
      };
}
