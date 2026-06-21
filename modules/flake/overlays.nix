{ ... }:
{
  flake.overlays.default = final: prev: {
    gnome-terminal = final.callPackage ../../pkgs/gnome-terminal-overlay.nix {
      inherit (prev) lib stdenv kitty makeWrapper;
      gnome-terminal = prev.gnome-terminal;
    };
  };
}
