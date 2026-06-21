# Declare flake.modules.<class>.<name> as deferredModules so files merge into them
# (flake-parts treats undeclared flake.modules as unique -> collisions).
{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
    description = "Dendritic module namespaces, keyed by class (nixos, homeManager, …) then feature name.";
  };
}
