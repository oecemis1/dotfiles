{
  config,
  pkgs,
  lib,
  ...
}:
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
        modules-center = [
          "custom/notifications"
          "clock"
          "custom/time"
        ];
        modules-right = [
          "custom/cpu"
          # "memory"
          # "custom/network"
          "tray"
          "wireplumber"
          # "bluetooth"
          "backlight"
          "custom/battery"
        ];

        backlight = {
          format = "󰖙 {percent}%";
          tooltip = false;
          on-click = "waybar_brightness_slider.sh";
        };

        bluetooth = {
          format = "󰂰 {status}";
          format-connected = "󰂰 {device_alias}";
          format-connected-battery = "󰂰 {device_alias} ({device_battery_percentage}%)";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        clock = {
          format = "󰃃 {:%a %d %b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            format = {
              months = "<span color='#bd93f9'><b>{}</b></span>";
              days = "<span color='#f8f8f2'>{}</span>";
              weekdays = "<span color='#8be9fd'><b>{}</b></span>";
              today = "<span color='#ff79c6'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "custom/battery" = {
          exec = "waybar_battery.sh";
          interval = 30;
          format = "{}";
          # on-click = "gnome-power-statistics";
          tooltip = false;
        };

        "custom/cpu" = {
          exec = "waybar_cpu.sh";
          interval = 5;
          format = "󰾆 {}";
          on-click = "kitty -e btop";
          tooltip = false;
        };

        "custom/network" = {
          exec = "waybar_network.sh";
          interval = 5;
          format = "{}";
          on-click = "nm-connection-editor";
          tooltip = false;
        };

        "custom/notifications" = {
          exec = "waybar_notifications.sh";
          interval = 5;
          format = "󰂜 {}";
          on-click = "swaync-client -t";
          tooltip = false;
        };

        "custom/time" = {
          exec = "date '+%H:%M'";
          interval = 1;
          format = "󰅐 {}";
          tooltip = false;
        };

        "custom/window" = {
          exec = "waybar_window.sh";
          interval = 1;
          format = "{}";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
          format-icons = {
            active = "●";
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
          tooltip = false;
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      @define-color base       #15161d;
      @define-color baselight  #44475a;
      @define-color text       #f8f8f2;
      @define-color yellow     #f1fa8c;
      @define-color purple     #bd93f9;
      @define-color surface2   #6272a4;
      @define-color hyprborder #44475a;

      * {
        padding: 0;
        font-family: "MonaspiceNe Nerd Font Mono";
        font-size: 17px;
      }

      window#waybar {
        background: alpha(@base, 0.65);
        border-radius: 3px;
        border: 1px solid alpha(@hyprborder, 0.4);
      }

      tooltip {
        background: @base;
      }

      tooltip label {
        color: @text;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        padding: 5px;
      }

      #backlight,
      #battery,
      #bluetooth,
      #clock,
      #cpu,
      #custom-battery,
      #custom-cpu,
      #custom-date,
      #custom-icon,
      #custom-network,
      #custom-notifications,
      #custom-power,
      #custom-time,
      #custom-window,
      #memory,
      #network,
      #tray,
      #wireplumber,
      #workspaces {
        color: @purple;
        padding: 1px 8px;
        margin: 0 2px;
        border-radius: 3px;
        border: 1px solid @baselight;
        background: alpha(@purple, .035);
      }

      #workspaces button {
        color: @purple;
      }

      #workspaces button.empty {
        color: @surface2;
      }
    '';
  };
}
