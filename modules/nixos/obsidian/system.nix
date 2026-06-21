{ ... }:
{
  flake.modules.nixos.obsidian =
    { ... }:
    {
      time.timeZone = "Europe/Istanbul";
      nix.settings = {
        max-jobs = 24;
        cores = 24;
      };
    };
}
