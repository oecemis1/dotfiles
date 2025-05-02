{
  config,
  pkgs,
  lib,
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
          source = ../../config/${name};
          recursive = true;
        };
      })
      (lib.filterAttrs
        (name: type: name != "README.md" && name != "fonts")
        (builtins.readDir ../../config));
  };
  
  # Create and manage necessary directories
  home.activation = {
    ensureConfigDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.config
    '';
  };
}
