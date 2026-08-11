# username/homeDirectory come from the NixOS HM module (and darwin later).
{ ... }:
{
  flake.modules.homeManager.cli =
    { self, ... }:
    {
      programs.home-manager.enable = true;
      nixpkgs.config.allowUnfree = true;
      # HM evaluates its own pkgs (no useGlobalPkgs), so the flake overlay
      # must be applied here too for home.packages to see it.
      nixpkgs.overlays = [ self.overlays.default ];
      fonts.fontconfig.enable = true;
      home.stateVersion = "26.05";
    };
}
