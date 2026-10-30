# Central color-scheme switch. Flip `colorScheme.flavor` below (or set it from
# a host module) and rebuild to retheme waybar, swaync, hyprland, kitty,
# tmux, neovim and yazi in one go. Both palettes stay in the repo permanently:
# kitty keeps dracula.conf/mocha.conf, yazi keeps its vendored flavors.
{ self, ... }:
{
  flake.modules.homeManager.cli =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Semantic palette: consumers use roles, not theme-specific color names.
      # accent is the primary (Dracula purple / Mocha maroon),
      # accent2 the secondary (Dracula cyan / Mocha peach).
      palettes = {
        catppuccin-mocha = {
          crust = "#11111b";
          base = "#1e1e2e";
          surface0 = "#313244";
          surface1 = "#45475a";
          overlay = "#6c7086";
          text = "#cdd6f4";
          accent = "#eba0ac";
          accent2 = "#fab387";
          urgent = "#f38ba8";
          red = "#f38ba8";
          green = "#a6e3a1";
          teal = "#94e2d5";
          yellow = "#f9e2af";
          orange = "#fab387";
          pink = "#f5c2e7";
        };
        dracula = {
          crust = "#15161d";
          base = "#282a36";
          surface0 = "#44475a";
          surface1 = "#44475a";
          overlay = "#6272a4";
          text = "#f8f8f2";
          accent = "#bd93f9";
          accent2 = "#8be9fd";
          urgent = "#ff79c6";
          red = "#ff5555";
          green = "#50fa7b";
          teal = "#8be9fd";
          yellow = "#f1fa8c";
          orange = "#ffb86c";
          pink = "#ff79c6";
        };
      };

      kittyThemes = {
        catppuccin-mocha = "mocha.conf";
        dracula = "dracula.conf";
      };

      # mytheme is the hand-tuned theme that inherits builtin dracula.
      helixThemes = {
        catppuccin-mocha = "catppuccin_mocha";
        dracula = "mytheme";
      };

      # dracula ships with btop; catppuccin_mocha is vendored in the repo.
      btopThemes = {
        catppuccin-mocha = "${self}/.config/btop/themes/catppuccin_mocha.theme";
        dracula = "${pkgs.btop}/share/btop/themes/dracula.theme";
      };

      colors = config.colorScheme.colors;
      # Soften selection colors against the palette base, keeping black text legible.
      tinted =
        color:
        let
          channel =
            offset:
            let
              value = lib.fromHexString (builtins.substring offset 2 color);
              base = lib.fromHexString (builtins.substring offset 2 colors.base);
            in
            lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString (builtins.div (value * 3 + base) 4)));
        in
        "#${channel 1}${channel 3}${channel 5}";
      yaziStyle = fg: {
        inherit fg;
        bg = "reset";
        reversed = false;
      };
      emphasized = fg: yaziStyle fg // { bold = true; };
      highlighted = color: emphasized "#000000" // { bg = tinted color; };
    in
    {
      options.colorScheme = {
        flavor = lib.mkOption {
          type = lib.types.enum (builtins.attrNames palettes);
          default = "catppuccin-mocha";
          description = "Color scheme applied across the desktop and terminal apps.";
        };
        colors = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          readOnly = true;
          description = "Semantic palette of the selected flavor.";
        };
      };

      config = {
        colorScheme.colors = palettes.${config.colorScheme.flavor};

        # kitty.conf does `include ./current-theme.conf`.
        xdg.configFile."kitty/current-theme.conf".source = "${self}/.config/kitty/${
          kittyThemes.${config.colorScheme.flavor}
        }";

        # helix config.toml does `theme = "current"`. Empty styles keep the
        # terminal transparency (same trick as mytheme); statusline/bufferline
        # become typography on the transparent material, and indent guides get
        # enough contrast to survive the blurred background.
        xdg.configFile."helix/themes/current.toml".text = ''
          inherits = "${helixThemes.${config.colorScheme.flavor}}"
          "ui.background" = {}
          "ui.statusline" = { fg = "${colors.text}" }
          "ui.statusline.inactive" = { fg = "${colors.overlay}" }
          "ui.bufferline" = { fg = "${colors.overlay}" }
          "ui.bufferline.active" = { fg = "${colors.accent}", modifiers = ["bold"] }
          "ui.bufferline.background" = {}
          "ui.virtual.indent-guide" = { fg = "${colors.overlay}" }
          "ui.virtual.ruler" = { bg = "${colors.crust}" }
        '';

        # btop.conf does `color_theme = "current"`.
        xdg.configFile."btop/themes/current.theme".source = btopThemes.${config.colorScheme.flavor};

        # init.lua does `colorscheme(require("current-theme"))`; the flavor
        # names double as the colorscheme names under .config/nvim/colors/.
        xdg.configFile."nvim/lua/current-theme.lua".text = ''
          return "${config.colorScheme.flavor}"
        '';

        # tmux.conf does `source-file ~/.config/tmux/current-theme.conf`.
        # Palette only — the styling lives in tmux.conf.
        xdg.configFile."tmux/current-theme.conf".text = ''
          set -g @theme_bg '${colors.base}'
          set -g @theme_crust '${colors.crust}'
          set -g @theme_current_line '${colors.surface0}'
          set -g @theme_fg '${colors.text}'
          set -g @theme_muted '${colors.overlay}'
          set -g @theme_accent '${colors.accent}'
          set -g @theme_accent2 '${colors.accent2}'
          set -g @theme_teal '${colors.teal}'
          set -g @theme_orange '${colors.orange}'
          set -g @theme_yellow '${colors.yellow}'
          set -g @theme_pink '${colors.pink}'
          set -g @theme_urgent '${colors.urgent}'
        '';

        # Keep file-type colors, icons and layout in the base; derive UI styles
        # from the same semantic palette as the desktop and Helix.
        xdg.configFile."yazi/theme.toml".source = (pkgs.formats.toml { }).generate "yazi-theme.toml" (
          lib.recursiveUpdate (builtins.fromTOML (builtins.readFile "${self}/.config/yazi/theme-base.toml")) {
            flavor.dark = config.colorScheme.flavor;
            app.overall = yaziStyle colors.text;

            mgr = {
              cwd = emphasized colors.text;
              find_keyword = yaziStyle colors.yellow // {
                bold = true;
                underline = true;
              };
              find_position = yaziStyle colors.accent2 // {
                italic = true;
              };
              symlink_target = yaziStyle colors.overlay;
              border_style = yaziStyle colors.overlay;
              marker_copied = {
                fg = colors.green;
                bg = colors.green;
              };
              marker_cut = {
                fg = colors.red;
                bg = colors.red;
              };
              marker_marked = {
                fg = colors.teal;
                bg = colors.teal;
              };
              marker_selected = {
                fg = colors.yellow;
                bg = colors.yellow;
              };
              count_copied = {
                fg = colors.crust;
                bg = colors.green;
              };
              count_cut = {
                fg = colors.crust;
                bg = colors.red;
              };
              count_selected = {
                fg = colors.crust;
                bg = colors.yellow;
              };
            };

            indicator = {
              parent = yaziStyle colors.overlay;
              current = highlighted colors.accent;
              preview = yaziStyle colors.accent2;
              padding = {
                open = "";
                close = "";
              };
            };

            tabs = {
              active = emphasized colors.accent;
              inactive = yaziStyle colors.overlay;
              sep_inner = {
                open = "";
                close = "";
              };
              sep_outer = {
                open = "";
                close = "";
              };
            };

            mode = {
              normal_main = emphasized colors.accent;
              normal_alt = yaziStyle colors.text;
              select_main = emphasized colors.teal;
              select_alt = yaziStyle colors.teal;
              unset_main = emphasized colors.orange;
              unset_alt = yaziStyle colors.orange;
            };

            status = {
              overall = yaziStyle colors.text;
              progress_label = emphasized colors.text;
              progress_normal = yaziStyle colors.accent2;
              progress_error = yaziStyle colors.red;
              perm_type = yaziStyle colors.accent2;
              perm_read = yaziStyle colors.yellow;
              perm_write = yaziStyle colors.red;
              perm_exec = yaziStyle colors.green;
              perm_sep = yaziStyle colors.overlay;
            };

            pick = {
              border = yaziStyle colors.accent;
              active = highlighted colors.accent2;
              inactive = yaziStyle colors.text;
            };

            input = {
              border = yaziStyle colors.accent;
              title = yaziStyle colors.text;
              value = yaziStyle colors.text;
              selected = {
                fg = colors.crust;
                bg = colors.accent2;
                reversed = false;
              };
            };

            cmp = {
              border = yaziStyle colors.accent;
              active = highlighted colors.accent2;
              inactive = yaziStyle colors.text;
            };

            tasks = {
              border = yaziStyle colors.accent;
              title = yaziStyle colors.text;
              hovered = highlighted colors.accent2 // {
                underline = true;
              };
            };

            which = {
              border = yaziStyle colors.accent;
              mask.bg = "reset";
              cand = yaziStyle colors.accent2;
              rest = yaziStyle colors.overlay;
              desc = yaziStyle colors.text;
              separator_style = yaziStyle colors.overlay;
            };

            help = {
              border = yaziStyle colors.accent;
              chord = yaziStyle colors.accent2;
              action = yaziStyle colors.text;
              hovered = highlighted colors.accent;
            };

            confirm = {
              border = yaziStyle colors.accent;
              title = emphasized colors.accent;
              body = yaziStyle colors.text;
              list = yaziStyle colors.overlay;
              btn_yes = emphasized colors.accent2;
              btn_no = yaziStyle colors.overlay;
            };

            spot = {
              border = yaziStyle colors.accent;
              title = emphasized colors.accent;
              tbl_col = emphasized colors.accent2;
              tbl_cell = highlighted colors.accent;
            };

            notify = {
              title_info = yaziStyle colors.green;
              title_warn = yaziStyle colors.yellow;
              title_error = yaziStyle colors.red;
            };
          }
        );
      };
    };
}
