{ inputs, lib, config, pkgs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Home Manager integrated on NixOS
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.csh = {
      home.stateVersion = "24.11";
      programs.starship.enable = true;
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.git = {
        enable = true;
        userName = "csh";
        userEmail = "csh@local";
        delta.enable = true;
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };
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
