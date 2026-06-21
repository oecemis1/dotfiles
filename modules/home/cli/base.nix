# username/homeDirectory come from the NixOS HM module (and darwin later).
{ ... }:
{
  flake.modules.homeManager.cli =
    { ... }:
    {
      programs.home-manager.enable = true;
      nixpkgs.config.allowUnfree = true;
      fonts.fontconfig.enable = true;
      home.stateVersion = "26.05";
    };
}
