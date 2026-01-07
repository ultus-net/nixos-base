{ config, pkgs, lib, ... }:
{
  home.stateVersion = "24.11";

  # Home Manager should manage itself.
  programs.home-manager.enable = true;

  # A practical default shell experience.
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 1200;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Cameron Hunter";
    userEmail = "admin@ultus.net";
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

  # VS Code managed by Home Manager (unfree). Swap to pkgs.vscodium if you
  # prefer the FOSS build.
  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      github.vscode-pull-request-github
      ms-python.python
      ms-python.vscode-pylance
      rust-lang.rust-analyzer
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
    ];
    userSettings = {
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnSave" = true;
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # everyday CLI
    eza ripgrep fd jq yq bat delta sd
    just
    gh
    hyperfine

    # editors/terminal
    foot

    # language servers
    nodePackages_latest.typescript-language-server
    nodePackages_latest.vscode-langservers-extracted
    marksman
  ];

  xdg.enable = true;
  xdg.userDirs.enable = true;
}
