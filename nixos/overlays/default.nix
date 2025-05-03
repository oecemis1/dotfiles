self: super: {
  gnome-terminal = self.callPackage ./gnome-terminal-overlay.nix {
    inherit (super) lib stdenv kitty makeWrapper;
    gnome-terminal = super.gnome-terminal;
  };
}
