{ ... }:
{
  flake.overlays.default = final: prev: {
    # removed from nixpkgs (murrine fallout); vendored in pkgs/
    dracula-theme = final.callPackage ../../pkgs/dracula-theme.nix { };

    gnome-terminal = final.callPackage ../../pkgs/gnome-terminal-overlay.nix {
      inherit (prev) lib stdenv kitty makeWrapper;
      gnome-terminal = prev.gnome-terminal;
    };
  };
}
