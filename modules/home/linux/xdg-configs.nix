# Linux-only ~/.config symlinks + the wallpapers dir. Portable configs are in
# cli/xdg-configs.nix.
{ self, ... }:
{
  flake.modules.homeManager.linux =
    { ... }:
    let
      immutable = name: {
        source = "${self}/.config/${name}";
        recursive = true;
      };
    in
    {
      xdg.configFile = {
        eww = immutable "eww";
        fonts = immutable "fonts";
        qalculate = immutable "qalculate";
        tofi = immutable "tofi";
        udiskie = immutable "udiskie";
        "mimeapps.list" = immutable "mimeapps.list";
        "GNOME-xdg-terminals.list" = immutable "GNOME-xdg-terminals.list";
        "xdg-terminals.list" = immutable "xdg-terminals.list";
      };

      home.file.".config/wallpapers" = {
        source = "${self}/assets";
        recursive = true;
        executable = false;
      };
    };
}
