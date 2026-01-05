{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    # Basics & QoL (inspired by Universal Blue)
    curl wget httpie
    git gh
    ripgrep fd sd
    eza bat delta
    jq yq
    just
    neovim
    starship
    direnv nix-direnv
    hyperfine
    bottom # system monitor
    btop
    fastfetch
    age
    gnupg
    wl-clipboard
    file
    unzip zip
    p7zip
    # Apps
    google-chrome
    spotify
  ];

  programs.bash.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.git.enable = true;
  programs.git.delta.enable = true;
  programs.git.extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
  };

  # VS Code (unfree) with common extensions
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      ms-python.python
      ms-python.vscode-pylance
      rust-lang.rust-analyzer
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
      github.vscode-pull-request-github
    ];
  };
}
