# Linux-only ~/.config symlinks + the wallpapers dir. Portable configs are in
# cli/xdg-configs.nix.
{ self, ... }:
{
  flake.modules.homeManager.linux =
    { config, ... }:
    let
      immutable = name: {
        source = "${self}/.config/${name}";
        recursive = true;
      };
      colors = config.colorScheme.colors;
    in
    {
      xdg.configFile = {
        eww = immutable "eww";

        # Palette for the eww widgets, generated from the colorScheme flavor.
        "eww/styles/_colors.scss".text = ''
          $crust: ${colors.crust};
          $surface0: ${colors.surface0};
          $surface1: ${colors.surface1};
          $overlay: ${colors.overlay};
          $text: ${colors.text};
          $accent: ${colors.accent};
          $accent2: ${colors.accent2};
        '';

        # tofi's config does `include = .../current-theme`.
        "tofi/current-theme".text = ''
          background-color = ${colors.base}
          prompt-color = ${colors.text}
          input-color = ${colors.green}
          input-background = ${colors.surface0}
          default-result-color = ${colors.overlay}
          selection-color = ${colors.accent2}
          selection-match-color = ${colors.green}
          border-color = ${colors.overlay}
        '';
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
