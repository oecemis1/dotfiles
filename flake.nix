{
  description = "NixOS and Home Manager configuration of orhun";

  inputs = {
    # Specify unstable nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Specify home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      # This makes home-manager use the same nixpkgs as we specified above
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # NixOS system configuration
      nixosConfigurations."odyssey" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
        ];
      };
      
      # Standalone Home Manager configuration
      homeConfigurations."orhun" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        # Specify home-manager configuration
        modules = [ ./home/home.nix ];
        
        # Explicitly pass unstable attribute to your config
        extraSpecialArgs = {
          unstable = pkgs;
          inherit inputs;
        };
      };
    };
}
