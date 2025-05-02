{
  description = "o config e";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      mkSystem =
        {
          baseConfigPath,
          hardwareConfigPath,
          system ? throw "You must specify system (e.g. x86_64-linux)",
          argOverrides ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs system;
          } // argOverrides;
          modules = [
            baseConfigPath
            hardwareConfigPath
            inputs.home-manager.nixosModules.home-manager
          ];
        };
    in {
      nixosConfigurations = {
        odyssey = mkSystem {
          baseConfigPath = ./nixos/odyssey/configuration.nix;
          hardwareConfigPath = ./nixos/odyssey/hardware-configuration.nix;
          system = "x86_64-linux";
        };
      };
    };
}
