{
  config,
  pkgs,
  lib,
  ...
}:
let
  colors = config.colorScheme.colors;
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 4;
        margin-top = 5;
        margin-bottom = 2;
        margin-left = 3;
        margin-right = 3;

        modules-left = [
          "hyprland/workspaces"
          # "custom/window"
        ];
        modules-center = [ ];
        modules-right = [
          "custom/battery"
          "custom/keyboard"
          "custom/cpu"
          # "memory"
          "tray"
          # merged into the control center (wifi/bluetooth/usb live there
          # too, as quick-setting tiles)
          # "wireplumber"
          # "backlight"
          # "custom/notifications"
          "custom/control-center"
          "clock"
        ];

        backlight = {
          format = "󰖙 {percent}%";
          tooltip = false;
          on-click = "eww-control-center-toggle";
          return-type = "";
          signal = 8;
        };

        # Clicking the clock opens the notification panel (which anchors to
        # the right, under it). The eww calendar is retired but kept around:
        # `eww-calendar-toggle` still works if bound somewhere again.
        clock = {
          format = "{:%a %d %b  %H:%M}";
          interval = 60;
          tooltip = false;
          on-click = "swaync-client -t";
        };

        "custom/battery" = {
          exec = "waybar_battery.sh";
          interval = 30;
          format = "{}";
          return-type = "json";
          tooltip = false;
        };

        "custom/cpu" = {
          exec = "waybar_cpu.sh";
          interval = 5;
          format = "󰾆 {}";
          on-click = "kitty -e btop";
          tooltip = false;
        };

        "custom/notifications" = {
          exec = "swaync-client -swb";
          restart-interval = 1;
          return-type = "json";
          format = "󰂜 {}";
          on-click = "swaync-client -t";
          tooltip = false;
        };

        "custom/control-center" = {
          format = "";
          on-click = "eww-control-center-toggle";
          tooltip = false;
        };

        "custom/window" = {
          exec = "waybar_window.sh";
          interval = 1;
          format = "{}";
        };

        # Event-driven layout indicator; the built-in hyprland/language
        # module blanks out when switching between the us,tr layouts.
        "custom/keyboard" = {
          exec = "waybar_keyboard.sh";
          restart-interval = 1;
          format = "{}";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
          format-icons = {
            active = "∙";
            urgent = "!";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
          };
          persistent_workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
            "7" = [ ];
            "8" = [ ];
          };
        };

        memory = {
          format = "󱇚 {used:0.1f}G";
          on-click = "kitty -e btop";
          tooltip = false;
        };

        tray = {
          icon-size = 16;
          spacing = 15;
        };

        wireplumber = {
          format = "󰕾 {volume}%";
          format-muted = "󰝟 {volume}%";
          tooltip = false;
          on-click = "eww-control-center-toggle";
          on-click-right = "pavucontrol";
        };
      };
    };

    style = ''
      @define-color base     ${colors.crust};
      @define-color surface1 ${colors.surface1};
      @define-color overlay  ${colors.overlay};
      @define-color text     ${colors.text};
      @define-color yellow   ${colors.yellow};
      @define-color teal     ${colors.teal};
      @define-color accent   ${colors.accent};
      @define-color urgent   ${colors.urgent};
      @define-color red      ${colors.red};

      * {
        padding: 0;
        font-family: "SF Pro Text", "MonaspiceNe Nerd Font Mono";
        font-size: 18px;
        /* Tabular numerals: ticking clock/percentages keep a fixed width */
        font-feature-settings: "tnum";
      }

      window#waybar {
        background: alpha(@base, 0.65);
        border-radius: 3px;
        border: 1px solid alpha(@surface1, 0.4);
      }

      tooltip {
        background: alpha(@base, 0.85);
        border: 1px solid alpha(@surface1, 0.6);
        border-radius: 6px;
      }

      tooltip label {
        color: @text;
        padding: 4px 6px;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        padding: 5px;
      }

      /* Modules are typography on the bar's material: slightly heavier
         weight for legibility over blur, color reserved for state. */
      #backlight,
      #clock,
      #custom-battery,
      #custom-cpu,
      #custom-keyboard,
      #custom-notifications,
      #custom-control-center,
      #custom-window,
      #memory,
      #tray,
      #wireplumber,
      #workspaces {
        color: @text;
        font-weight: 500;
        padding: 1px 8px;
        margin: 0 2px;
        border-radius: 3px;
      }

      /* Clickable modules get press/hover feedback: a soft chip fades in
         under the pointer; press responds instantly and reads stronger. */
      #backlight,
      #clock,
      #custom-cpu,
      #custom-notifications,
      #custom-control-center,
      #wireplumber,
      #workspaces button {
        transition: background-color 120ms ease-out, color 120ms ease-out;
      }

      #backlight:hover,
      #clock:hover,
      #custom-cpu:hover,
      #custom-notifications:hover,
      #custom-control-center:hover,
      #wireplumber:hover,
      #workspaces button:hover {
        background: alpha(@text, 0.08);
      }

      #backlight:active,
      #clock:active,
      #custom-cpu:active,
      #custom-notifications:active,
      #custom-control-center:active,
      #wireplumber:active,
      #workspaces button:active {
        background: alpha(@text, 0.14);
      }

      #workspaces button {
        color: @text;
        font-weight: 500;
        padding: 0 4px;
        border-radius: 3px;
      }

      #workspaces button.empty {
        color: @overlay;
      }

      #workspaces button.active {
        color: @accent;
      }

      #workspaces button.urgent {
        color: @urgent;
      }

      /* State feedback: steady colors, no pulsing. Charging is teal, not
         green, so it never rides the red-green axis against .critical.
         The color transition bridges the plug/unplug state snap. */
      #custom-battery {
        transition: color 200ms ease-out;
      }

      #custom-battery.charging {
        color: @teal;
      }

      #custom-battery.warning {
        color: @yellow;
      }

      #custom-battery.critical {
        color: @red;
      }

      #wireplumber.muted {
        color: @overlay;
      }

      #custom-notifications.dnd-none,
      #custom-notifications.dnd-notification {
        color: @overlay;
      }
    '';
  };
}
