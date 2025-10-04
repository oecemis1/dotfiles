{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      source = ~/.config/hypr/monitors.conf
    '';
    settings = {
      "$terminal" = "kitty";
      "$browser" = "google-chrome-stable";
      "$fileManager" = "yazi_cd";
      "$launcher" = "pkill tofi || tofi-drun | xargs hyprctl dispatch exec --";
      "$editor" = "hx";
      "$mainMod" = "SUPER";

      # Monitor configuration
      # monitor = ",preferred,auto,auto";

      xwayland = {
        enabled = true;
        force_zero_scaling = true;
      };

      # General settings
      general = {
        border_size = 1;
        no_border_on_floating = true;
        gaps_in = 2;
        gaps_out = 3;
        "col.active_border" = "rgba(44475aff)";
        "col.inactive_border" = "rgba(1e1f2900)";
        layout = "dwindle";
        extend_border_grab_area = true;
        hover_icon_on_border = true;
      };

      # Decoration settings
      decoration = {
        rounding = 5;

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

      animations = {
        enabled = "yes, please :)";

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # Dwindle layout settings
      dwindle = {
        pseudotile = false;
        force_split = 0;
        preserve_split = true;
        smart_split = false;
        special_scale_factor = 0.9;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        default_split_ratio = 1.0;
      };

      # Master layout settings
      master = {
        allow_small_split = false;
        special_scale_factor = 0.9;
        mfact = 0.55;
        new_status = "master";
        new_on_top = false;
        # no_gaps_when_only = false;
        orientation = "left";
        inherit_fullscreen = true;
      };

      # Misc settings
      misc = {
        # force_default_wallpaper = -1;
        disable_hyprland_logo = true;
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = true;
        focus_on_activate = true;
      };
      # Workaround for #6038 / #6237
      # initial_workspace_tracking = false;

      # Gestures
      gestures = {
        workspace_swipe = false;
      };

      device = {
        "name" = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Window rules
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      windowrulev2 = [
        #VideoBridge
        "workspace 1, class:^(xwaylandvideobridge)$"
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
        "float, class:^(org.gnome.Calculator)"
        "workspace 1,class:(google-chrome)"
        "workspace 2,class:(kitty)"
        "float, class:^(org.gnome.Nautilus)"
        "float, title:^(my_todo)$"
        "size 80% 80%, title:^(my_todo)$"
        "center, title:^(my_todo)$"
        "workspace special:todo, title:^(my_todo)$"
        "float, title:^(Brightness Control)$"
        "noinitialfocus, title:^(Brightness Control)$"
        "noblur, title:^(Brightness Control)$"
        "float, class:^(org.pulseaudio.pavucontrol)$"
        "float, class:^(.blueman-manager-wrapped)$"
        #qalculate
        "float,class:(qalculate-qt)"
        "float,class:(io.github.Qalculate.qalculate-qt)"
        "workspace special:calculator,class:(qalculate-qt)"
        "workspace special:calculator,class:(io.github.Qalculate.qalculate-qt)"
      ];

      layerrule = [
        "blur,waybar"
        "ignorealpha 0.3,waybar"
        "blur,swaync-control-center"
        "blur,swaync-notification-window"
        "ignorealpha 0.3,swaync-control-center"
        "ignorealpha 0.3,swaync-notification-window"
        "noanim,selection"
        "noanim,slurp"
        "blur,tofi"
        "ignorealpha 0.3,tofi"
      ];

      bind = [
        "$mainMod, Q, killactive,"
        # "$mainMod, Escape, exec, if hyprctl monitors -j | jq -e '.[] | select(.dpmsStatus == true)' > /dev/null; then hyprctl dispatch dpms off; else hyprctl dispatch dpms on; fi"
        "CTRL ALT, Escape, exit,"
        "$mainMod, Escape, exec, hyprlock"
        "$mainMod, B, exec, pkill waybar || waybar"
        "$mainMod, Tab, focuscurrentorlast"

        "ALT, Tab, focuscurrentorlast"
        "ALT, M, workspace, 1"
        "ALT, COMMA, workspace, 2"
        "ALT, PERIOD, workspace, 3"
        "ALT, SLASH, workspace, 4"

        # Focus movement
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, j, movefocus, u"
        "$mainMod, k, movefocus, d"

        "$mainMod, E, togglefloating"
        "$mainMod, F, fullscreen"
        "$mainMod, P, pseudo"
        "$mainMod, O, togglesplit"
        "$mainMod, S, swapsplit"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace
        # "$mainMod, S, togglespecialworkspace, magic"
        # "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        "CTRL ALT, T, exec, $terminal"
        "ALT, N, exec, todo_my"

        "$mainMod SHIFT, S, exec, pgrep hyprshot || hyprshot -m region -o $HOME/Pictures/Screenshots"
        "CTRL ALT, U, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "CTRL ALT, I, exec, grim -g \"$(hyprctl clients -j | jq -r '.[] | \"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1]) \\(.title)\"' | slurp -r)\" - | swappy -f -"
      ];

      binde = [
        "$mainMod CTRL, H, resizeactive, -20 0"
        "$mainMod CTRL, J, resizeactive, 0 20"
        "$mainMod CTRL, K, resizeactive, 0 -20"
        "$mainMod CTRL, L, resizeactive, 20 0"
      ];

      # Bind on release
      bindr = [
        "SUPER, SUPER_L, exec, $launcher"
        "SUPER, SUPER_R, exec, $launcher"
      ];

      # Bind with repeat
      bindel = [
        ", XF86AudioRaiseVolume , exec, swayosd-client --output-volume +5"
        ", XF86AudioLowerVolume , exec, swayosd-client --output-volume -5"
        # ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        # ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        # ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        # ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        # ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Bind locked
      bindl = [
        ", XF86AudioMute        , exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute     , exec, swayosd-client --input-volume  mute-toggle"
        ", XF86MonBrightnessUp  , exec, swayosd-client --brightness +10"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -10"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
