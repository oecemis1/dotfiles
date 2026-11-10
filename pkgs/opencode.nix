{
  lib,
  opencode,
}:
assert lib.assertMsg (
  opencode.version == "2.2.5"
) "Recheck the OpenCode dependency hash correction when updating from 2.2.5.";
opencode.overrideAttrs (old: {
  node_modules = old.node_modules.overrideAttrs {
    # The packaged hash was generated with Bun 1.4.2, before nixpkgs updated to 1.4.4.
    outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
  };
})
