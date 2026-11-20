{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.callPackage ../../../pkgs/asus-lighting.nix { })
      ];
    };
}
