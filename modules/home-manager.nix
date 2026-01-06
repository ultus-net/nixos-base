{ inputs, lib, config, pkgs, ... }:
{
  # Integrate Home Manager into NixOS. We import the Home Manager module
  # and provide a small example user `csh` with common user-level tools
  # and program settings managed by Home Manager.
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Home Manager configuration exposed by this module. We set a couple of
  # global flags and configure a sample user `csh` with useful defaults.
  home-manager = {
    useGlobalPkgs = true;    # allow home-manager to use globally built pkgs
    useUserPackages = true;   # allow per-user packages in the home environment
    users.csh = {
      home.stateVersion = "24.11"; # recommended Home Manager state version

      # Enable common user programs via Home Manager
      programs.starship.enable = true;
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      # Git configuration applied via Home Manager for the example user
      programs.git = {
        enable = true;
        userName = "csh";
        userEmail = "csh@local";
        delta.enable = true; # enable delta as a pager for git
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      # Neovim example configuration with a small plugin list
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

      # Common user packages installed to the user's home via Home Manager
      home.packages = with pkgs; [
        eza ripgrep fd jq yq delta sd
        just gh bat hyperfine
        nodePackages_latest.typescript-language-server
        nodePackages_latest.vscode-langservers-extracted
        marksman
        foot
      ];
    };
  };
}
