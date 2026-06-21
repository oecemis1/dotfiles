# Pulls the homeManager.* modules into the host via the flake-parts config.
{
  inputs,
  config,
  self,
  ...
}:
{
  flake.modules.nixos.core =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit inputs self; };
        users.orhun.imports = [
          config.flake.modules.homeManager.cli
          config.flake.modules.homeManager.linux
        ];
      };
    };
}
