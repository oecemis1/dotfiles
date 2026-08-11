{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  lua = lib.generators.mkLuaInline;

  terminal = "kitty --single-instance";
  # tofi launches the entry itself: 0.56's `hyprctl dispatch` takes lua
  # syntax, so the old `| xargs hyprctl dispatch exec --` pipe is dead
  launcher = "pkill tofi || tofi-drun --drun-launch=true";

  # Dispatcher helpers rendering hl.dsp.* calls. Values are spliced into a
  # quoted Lua string, so commands must not contain `"` or `\`.
  dsp = {
    exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
    close = lua "hl.dsp.window.close()";
    exit = lua "hl.dsp.exit()";
    floatToggle = lua ''hl.dsp.window.float({ action = "toggle" })'';
    fullscreen = lua "hl.dsp.window.fullscreen()";
    pseudo = lua "hl.dsp.window.pseudo()";
    layoutMsg = msg: lua ''hl.dsp.layout("${msg}")'';
    focusDir = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
    focusLast = lua "hl.dsp.focus({ last = true })";
    focusWorkspace = ws: lua "hl.dsp.focus({ workspace = ${wsArg ws} })";
    moveToWorkspace = ws: lua "hl.dsp.window.move({ workspace = ${wsArg ws} })";
    resizeBy = x: y: lua "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })";
    drag = lua "hl.dsp.window.drag()";
    resize = lua "hl.dsp.window.resize()";
    # deferred via hl.timer per the wiki: dpms straight from a bind is
    # undefined behavior
    dpms = action: lua ''
      function()
        hl.timer(function()
          hl.dispatch(hl.dsp.dpms({ action = "${action}" }))
        end, { timeout = 500, type = "oneshot" })
      end'';
  };
  # numbered workspaces are integers; "e+1" / "special:x" stay strings
  wsArg = ws: if builtins.isInt ws then toString ws else ''"${ws}"'';

  bind = keys: dispatcher: { _args = [ keys dispatcher ]; };
  bindFlags = keys: dispatcher: flags: { _args = [ keys dispatcher flags ]; };

  # SUPER+1..0 focus / SUPER+SHIFT+1..0 move (workspace 10 on key 0)
  workspaceBinds = lib.concatMap (
    i:
    let
      key = toString (lib.mod i 10);
    in
    [
      (bind "SUPER + ${key}" (dsp.focusWorkspace i))
      (bind "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i))
    ]
  ) (lib.range 1 10);
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    # monitors.lua is written by nwg-displays; pcall so a missing file
    # doesn't abort the rest of the config.
    extraConfig = ''
      pcall(require, "monitors")
    '';
    settings = {
      config = {
        ecosystem.no_update_news = true;

        xwayland = {
          enabled = true;
          force_zero_scaling = true;
        };

        general = {
          border_size = 1;
          gaps_in = 2;
          gaps_out = 3;
          col = {
            active_border = "rgba(${lib.removePrefix "#" config.colorScheme.colors.surface1}ff)";
            inactive_border = "rgba(1e1f2900)";
          };
          layout = "dwindle";
          extend_border_grab_area = true;
          hover_icon_on_border = true;
        };

        decoration = {
          rounding = 2;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            new_optimizations = true;
            ignore_opacity = false;
            noise = 0.05;
            size = 2;
            passes = 3;
          };
        };

        animations.enabled = true;

        dwindle = {
          force_split = 0;
          preserve_split = true;
          smart_split = false;
          special_scale_factor = 0.9;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
          default_split_ratio = 1.0;
        };

        master = {
          allow_small_split = false;
          special_scale_factor = 0.9;
          mfact = 0.55;
          new_status = "master";
          new_on_top = false;
          orientation = "left";
        };

        misc = {
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = false;
          key_press_enables_dpms = true;
          focus_on_activate = true;
        };
      };

      curve = [
        { _args = [ "easeOutQuint" { type = "bezier"; points = [ [ 0.23 1.0 ] [ 0.32 1.0 ] ]; } ]; }
        { _args = [ "easeInOutCubic" { type = "bezier"; points = [ [ 0.65 0.05 ] [ 0.36 1.0 ] ]; } ]; }
        { _args = [ "almostLinear" { type = "bezier"; points = [ [ 0.5 0.5 ] [ 0.75 1.0 ] ]; } ]; }
        { _args = [ "quick" { type = "bezier"; points = [ [ 0.15 0.0 ] [ 0.1 1.0 ] ]; } ]; }
        # Critically damped (2*sqrt(stiffness*mass)): settles with no
        # overshoot - nothing here is momentum-driven, so no bounce.
        { _args = [ "standard" { type = "spring"; mass = 1; stiffness = 300; dampening = 34.6; } ]; }
      ];

      # Geometry rides the spring; fades and color stay on beziers. Enter
      # and exit share a path (popin both ways), exits run quicker than
      # entrances, and windows/windowsIn share one clock so a dwindle
      # split reads as a single motion: the sibling's edge retreats while
      # the newcomer grows into the opening.
      animation = [
        { leaf = "global"; enabled = true; speed = 3.0; bezier = "easeOutQuint"; }
        # focus flips constantly; keep the border color change out of the way
        { leaf = "border"; enabled = true; speed = 2.0; bezier = "easeOutQuint"; }
        { leaf = "windows"; enabled = true; speed = 3.0; spring = "standard"; }
        { leaf = "windowsIn"; enabled = true; speed = 3.0; spring = "standard"; style = "popin 80%"; }
        { leaf = "windowsOut"; enabled = true; speed = 2.0; bezier = "easeOutQuint"; style = "popin 80%"; }
        { leaf = "fadeIn"; enabled = true; speed = 1.7; bezier = "almostLinear"; }
        { leaf = "fadeOut"; enabled = true; speed = 1.5; bezier = "almostLinear"; }
        { leaf = "fade"; enabled = true; speed = 2.5; bezier = "quick"; }
        { leaf = "layers"; enabled = true; speed = 2.5; bezier = "easeOutQuint"; }
        { leaf = "layersIn"; enabled = true; speed = 2.5; bezier = "easeOutQuint"; style = "fade"; }
        { leaf = "layersOut"; enabled = true; speed = 2.0; bezier = "easeOutQuint"; style = "fade"; }
        { leaf = "fadeLayersIn"; enabled = true; speed = 1.8; bezier = "almostLinear"; }
        { leaf = "fadeLayersOut"; enabled = true; speed = 1.4; bezier = "almostLinear"; }
        # a 15% slide hints which way you moved; one clock for both sides
        { leaf = "workspaces"; enabled = true; speed = 2.0; bezier = "easeOutQuint"; style = "slidefade 15%"; }
        # calculator/todo specials drop in from the top
        { leaf = "specialWorkspace"; enabled = true; speed = 2.5; bezier = "easeOutQuint"; style = "slidefadevert 15%"; }
      ];

      window_rule = [
        { match = { float = true; }; border_size = 0; }

        # VideoBridge
        {
          match = { class = "^(xwaylandvideobridge)$"; };
          workspace = "1";
          opacity = "0.0 override";
          no_anim = true;
          no_initial_focus = true;
          max_size = [ 1 1 ];
          no_blur = true;
          no_focus = true;
        }

        # Browser
        { match = { class = "(google-chrome)"; }; workspace = "1"; }
        { match = { class = "(firefox)"; }; workspace = "1"; }

        { match = { class = "^(org.gnome.Calculator)"; }; float = true; }

        { match = { class = "^(termfilechooser)$"; }; float = true; }
        {
          match = { title = "^(termfilechooser)$"; };
          float = true;
          size = [ "80%" "60%" ];
          center = true;
        }
        { match = { class = "^(kitty)$"; initial_title = "^(kitty)$"; }; workspace = "2"; }

        { match = { class = "^(org.gnome.Nautilus)"; }; float = true; }
        {
          match = { title = "^(my_todo)$"; };
          float = true;
          size = [ 1380 1011 ];
          center = true;
          workspace = "special:todo";
        }
        {
          match = { title = "^(Brightness Control)$"; };
          float = true;
          no_initial_focus = true;
          no_blur = true;
        }
        { match = { class = "^(org.pulseaudio.pavucontrol)$"; }; float = true; }

        # deep-config apps behind the wifi/bluetooth/usb bar widgets
        { match = { class = "^(nm-connection-editor)$"; }; float = true; }
        { match = { class = "^(io.github.kaii_lb.Overskride)$"; }; float = true; }
        { match = { class = "^(gnome-disks)$"; }; float = true; }
        { match = { class = "^(org.gnome.DiskUtility)$"; }; float = true; }

        # yazi browsing a usb stick, spawned by the usb menu's folder button
        {
          match = { initial_title = "^(usb-browse)$"; };
          float = true;
          size = [ "60%" "60%" ];
          center = true;
        }

        # qalculate
        { match = { class = "(qalculate-qt)"; }; float = true; workspace = "special:calculator"; }
        { match = { class = "(io.github.Qalculate.qalculate-qt)"; }; float = true; workspace = "special:calculator"; }

        # matplotlib
        { match = { class = "(Matplotlib)"; }; float = true; }
      ];

      layer_rule =
        map (namespace: { match = { inherit namespace; }; blur = true; ignore_alpha = 0.3; }) [
          "waybar"
          "swaync-control-center"
          "swaync-notification-window"
          "tofi"
          "calendar"
          "brightness_slider"
          "power_menu"
          "control_center"
        ]
        # Surfaces that own their motion (or shouldn't have any) skip the
        # compositor's layer fade: tofi is keyboard-summoned dozens of
        # times a day and must appear instantly; the eww control center
        # animates via its revealer.
        ++ map (namespace: { match = { inherit namespace; }; no_anim = true; }) [
          "tofi"
          "control_center"
          "control_center_closer"
        ]
        # swaync has no panel animation of its own (verified: it snaps
        # with no_anim) - the compositor slides it in from the top edge,
        # matching the control center's drop-down.
        ++ [
          { match = { namespace = "swaync-control-center"; }; animation = "slide"; }
        ];

      bind = [
        (bind "SUPER + Q" dsp.close)
        (bind "CTRL + ALT + Escape" dsp.exit)
        (bind "SUPER + Escape" (dsp.exec "hyprlock"))
        (bind "SUPER + B" (dsp.exec "pkill waybar || waybar"))
        (bind "SUPER + Tab" dsp.focusLast)

        (bind "ALT + Tab" dsp.focusLast)
        (bind "ALT + M" (dsp.focusWorkspace 1))
        (bind "ALT + COMMA" (dsp.focusWorkspace 2))
        (bind "ALT + PERIOD" (dsp.focusWorkspace 3))
        (bind "ALT + SLASH" (dsp.focusWorkspace 4))

        # Focus movement
        (bind "SUPER + h" (dsp.focusDir "left"))
        (bind "SUPER + l" (dsp.focusDir "right"))
        (bind "SUPER + j" (dsp.focusDir "up"))
        (bind "SUPER + k" (dsp.focusDir "down"))

        (bind "SUPER + E" dsp.floatToggle)
        (bind "SUPER + F" dsp.fullscreen)
        (bind "SUPER + P" dsp.pseudo)
        (bind "SUPER + O" (dsp.layoutMsg "togglesplit"))
        (bind "SUPER + S" (dsp.layoutMsg "swapsplit"))

        # Scroll through workspaces
        (bind "SUPER + mouse_down" (dsp.focusWorkspace "e+1"))
        (bind "SUPER + mouse_up" (dsp.focusWorkspace "e-1"))

        (bind "CTRL + ALT + T" (dsp.exec terminal))
        (bind "ALT + N" (dsp.exec "todo_my"))

        (bind "SUPER + SHIFT + S" (dsp.exec "pgrep hyprshot || hyprshot -m region -o $HOME/Pictures/Screenshots"))

        # Window resizing (was binde)
        (bindFlags "SUPER + CTRL + H" (dsp.resizeBy (-20) 0) { repeating = true; })
        (bindFlags "SUPER + CTRL + J" (dsp.resizeBy 0 20) { repeating = true; })
        (bindFlags "SUPER + CTRL + K" (dsp.resizeBy 0 (-20)) { repeating = true; })
        (bindFlags "SUPER + CTRL + L" (dsp.resizeBy 20 0) { repeating = true; })

        # Launcher on bare Super tap (was bindr)
        (bindFlags "SUPER + SUPER_L" (dsp.exec launcher) { release = true; })
        (bindFlags "SUPER + SUPER_R" (dsp.exec launcher) { release = true; })

        # Media/brightness keys, active on the lockscreen too (was bindel/bindl)
        (bindFlags "XF86AudioRaiseVolume" (dsp.exec "swayosd-client --output-volume +5") { locked = true; repeating = true; })
        (bindFlags "XF86AudioLowerVolume" (dsp.exec "swayosd-client --output-volume -5") { locked = true; repeating = true; })
        (bindFlags "XF86AudioMute" (dsp.exec "swayosd-client --output-volume mute-toggle") { locked = true; })
        (bindFlags "XF86AudioMicMute" (dsp.exec "swayosd-client --input-volume mute-toggle") { locked = true; })
        (bindFlags "XF86MonBrightnessUp" (dsp.exec "swayosd-client --brightness +10") { locked = true; })
        (bindFlags "XF86MonBrightnessDown" (dsp.exec "swayosd-client --brightness -10") { locked = true; })
        (bindFlags "XF86AudioNext" (dsp.exec "playerctl next") { locked = true; })
        (bindFlags "XF86AudioPause" (dsp.exec "playerctl play-pause") { locked = true; })
        (bindFlags "XF86AudioPlay" (dsp.exec "playerctl play-pause") { locked = true; })
        (bindFlags "XF86AudioPrev" (dsp.exec "playerctl previous") { locked = true; })
        (bindFlags "switch:on:Lid Switch" (dsp.dpms "disable") { locked = true; })
        (bindFlags "switch:off:Lid Switch" (dsp.dpms "enable") { locked = true; })

        # Mouse move/resize (was bindm)
        (bindFlags "SUPER + mouse:272" dsp.drag { mouse = true; })
        (bindFlags "SUPER + mouse:273" dsp.resize { mouse = true; })
      ]
      ++ workspaceBinds;
    };
  };
}
