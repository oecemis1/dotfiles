{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Configure XDG directories to manage mutable configs
  xdg = {
    enable = true;
    
    # Map files from the config directory to ~/.config
    configFile = lib.mapAttrs'
      (name: type: {
        name = name;
        value = {
          source = "${inputs.self}/config/${name}";
          recursive = true;
        };
      })
      (lib.filterAttrs
         (name: type: name != "README.md" && name != ".gitkeep")
         (builtins.readDir "${inputs.self}/config/"));
  };
}
