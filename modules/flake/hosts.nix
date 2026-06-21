{ inputs, config, self, ... }:
let
  mkHost =
    hostName:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        config.flake.modules.nixos.core
        config.flake.modules.nixos.desktop
        config.flake.modules.nixos.${hostName}
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.overlays = [ self.overlays.default ];
          networking.hostName = hostName;
          system.stateVersion = "25.05";
        }
      ];
    };
in
{
  systems = [ "x86_64-linux" ];

  flake.nixosConfigurations = {
    odyssey = mkHost "odyssey";
    obsidian = mkHost "obsidian";
  };
}
