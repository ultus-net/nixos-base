{ inputs, lib, config, pkgs, ... }:
{
  # Integrate Home Manager into NixOS.
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Global flags for Home Manager.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    # Optionally pass extra arguments to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    
    # Default user configurations can be set here
    # Or users can import their own configs in their machine configuration
    # Example:
    # users.yourusername = import ../home/yourusername.nix;
  };
}

