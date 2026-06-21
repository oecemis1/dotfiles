{ ... }:
{
  flake.modules.nixos.core =
    { lib, pkgs, ... }:
    {
      nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate =
          p:
          builtins.all (
            license:
            license.free
            || builtins.elem (license.shortName or "unknown") [
              "CUDA EULA"
              "cuDNN EULA"
              "cuTENSOR EULA"
              "NVidia OptiX EULA"
              "unfree"
            ]
          ) (lib.lists.toList (p.meta.license or [ ]));
      };

      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        settings = {
          trusted-users = [
            "root"
            "orhun"
          ];

          substituters = [
            "https://cache.nixos.org/"
            "https://ai.cachix.org"
            "https://nix-community.cachix.org"
            "https://cuda-maintainers.cachix.org"
            "https://numtide.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          ];

          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;

          keep-outputs = true;
          keep-derivations = true;

          max-substitution-jobs = 256;
        };
      };
    };
}
