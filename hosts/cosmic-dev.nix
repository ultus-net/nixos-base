{ config, pkgs, lib, inputs, ... }:
{
  # Import reusable module fragments from `modules/` so this host is composed
  # from small, desktop-agnostic pieces. The `inputs` argument is passed in
  # from the top-level flake via `specialArgs` when building a nixosSystem.
  imports = [
    ../modules/common-packages.nix
    ../modules/cosmic.nix
    ../modules/home-manager.nix
    ../modules/qol.nix
    ../modules/development.nix
  ];

  # Basic machine identity
  networking.hostName = "cosmic-dev";
  time.timeZone = "UTC";

  # Enable common package bundle and add a couple extras for convenience
  commonPackages.enable = true;
  commonPackages.packages = [ pkgs.git pkgs.curl ];

  # Make sure a local user exists (home-manager will manage dotfiles)
  users.users.csh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  # Enable SSH for remote administration during testing
  services.openssh.enable = true;

  # Relax sudo for developer convenience on this example host (optional)
  security.sudo.wheelNeedsPassword = false;
}
