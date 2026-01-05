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


  # Program-specific settings (starship, direnv, git, neovim, etc.) are
  # managed via Home Manager in `modules/home-manager.nix` so we only
  # configure system-level packages here.

  # VS Code user-level installation and extensions are handled by Home
  # Manager in `modules/home-manager.nix` (so we don't declare
  # `programs.vscode` here at the NixOS module level).
}
