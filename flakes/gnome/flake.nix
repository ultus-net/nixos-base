{
  description = "Small flake exposing a GNOME workstation configuration built from the repo modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        nixosConfigurations = {
          gnome-workstation = pkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ../../hosts/gnome-workstation.nix
            ];
            specialArgs = { inputs = self.inputs; };
          };
        };
      }
    );
}
