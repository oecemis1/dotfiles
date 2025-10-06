{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.user.services.swaync = {
    Service = {
      ExecStart = lib.mkForce "${pkgs.swaynotificationcenter}/bin/swaync -c ${config.xdg.configHome}/swaync/config.json -s ${config.xdg.configHome}/swaync/style.css";
      Environment = [
        "XDG_CONFIG_HOME=%h/.dummy"
      ];
      UnsetEnvironment = "GTK_THEME";
    };
  };

  services.swaync = {
    enable = true;

    settings = {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "center";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 10;
      control-center-margin-bottom = 20;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-2fa-action = true;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      # fit-to-screen = true;
      fit-to-screen = false;
      relative-timestamps = true;
      control-center-width = 450;
      # control-center-height = 700;
      notification-window-width = 350;
      keyboard-shortcuts = true;
      image-visibility = "never";
      transition-time = 200;
      hide-on-clear = true;
      hide-on-action = true;
      script-fail-notify = true;

      notification-visibility = {
        example-name = {
          state = "muted";
          urgency = "Low";
          app-name = "Abc";
        };
      };

      widgets = [
        "inhibitors"
        "title"
        "dnd"
        "notifications"
      ];

      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        notifications = {
          clear-all-button = true;
        };
      };
    };

    style = ''
      * {
        all: unset;
        font-size: 14px;
        font-family: "Noto Sans";
        transition: 200ms;
      }

      .floating-notifications.background .notification-row .notification-background {
        border-radius: 12.6px;
        margin: 18px;
        background-color: #282a36;
        color: #f8f8f2;
        padding: 0;
        opacity: 0.8;
      }

      .floating-notifications.background .notification-row .notification-background .notification {
        padding: 7px;
        border-radius: 12.6px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content {
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
        color: #f8f8f2;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
        color: #8be9fd;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
        color: #f8f8f2;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: #f8f8f2;
        background-color: #44475a;
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: #6272a4;
        color: #f8f8f2;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: #bd93f9;
        color: #f8f8f2;
      }

      .floating-notifications.background .notification-row .notification-background .close-button {
        margin: 7px;
        padding: 2px;
        border-radius: 6.3px;
        color: #282a36;
        background-color: #ff5555;
      }

      .floating-notifications.background .notification-row .notification-background .close-button:hover {
        background-color: #f8f8f2;
        color: #282a36;
      }

      .floating-notifications.background .notification-row .notification-background .close-button:active {
        background-color: #ff5555;
        color: #282a36;
      }

      .control-center {
        border-radius: 12.6px;
        margin: 18px;
        background-color: #282a36;
        color: #f8f8f2;
        padding: 14px;
        opacity: 0.8;
        max-height: calc(100vh - 60px);
        overflow-y: auto;
      }

      .control-center .widget-title {
        color: #f8f8f2;
        font-size: 1.3em;
      }

      .control-center .widget-title button {
        border-radius: 7px;
        color: #f8f8f2;
        background-color: #44475a;
        padding: 8px;
      }

      .control-center .widget-title button:hover {
        background-color: #50fa7b;
        color: #282a36;
      }

      .control-center .widget-title button:active {
        background-color: #bd93f9;
        color: #282a36;
      }

      .control-center .notification-row .notification-background {
        border-radius: 7px;
        color: #f8f8f2;
        background-color: #44475a;
        margin-top: 14px;
      }

      .control-center .notification-row .notification-background .notification {
        padding: 7px;
        border-radius: 7px;
      }

      .control-center .notification-row .notification-background .notification .notification-content {
        margin: 7px;
      }

      .control-center .notification-row .notification-background .notification .notification-content .summary {
        color: #f8f8f2;
      }

      .control-center .notification-row .notification-background .notification .notification-content .time {
        color: #8be9fd;
      }

      .control-center .notification-row .notification-background .notification .notification-content .body {
        color: #f8f8f2;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: #f8f8f2;
        background-color: #6272a4;
        margin: 7px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: #44475a;
        color: #f8f8f2;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: #bd93f9;
        color: #f8f8f2;
      }

      .control-center .notification-row .notification-background .close-button {
        margin: 7px;
        padding: 2px;
        border-radius: 6.3px;
        color: #282a36;
        background-color: #f8f8f2;
      }

      .control-center .notification-row .notification-background .close-button:hover {
        background-color: #ff5555;
        color: #282a36;
      }

      .control-center .notification-row .notification-background .close-button:active {
        background-color: #ff5555;
        color: #282a36;
      }

      .control-center .notification-row .notification-background:hover {
        background-color: #6272a4;
        color: #f8f8f2;
      }

      .control-center .notification-row .notification-background:active {
        background-color: #bd93f9;
        color: #f8f8f2;
      }

      progressbar,
      progress,
      trough {
        border-radius: 12.6px;
      }

      .notification.critical progress {
        background-color: #ff5555;
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: #bd93f9;
      }

      trough {
        background-color: #44475a;
      }

      .control-center trough {
        background-color: #6272a4;
      }

      .control-center-dnd {
        margin-top: 5px;
        border-radius: 8px;
        background: #44475a;
        border: 1px solid #6272a4;
      }

      .control-center-dnd:checked {
        background: #44475a;
      }

      .control-center-dnd slider {
        background: #6272a4;
        border-radius: 8px;
      }

      .widget-dnd {
        margin: 0px;
        font-size: 1.1rem;
      }

      .widget-dnd > switch {
        font-size: initial;
        border-radius: 8px;
        background: #44475a;
        border: 1px solid #6272a4;
      }

      .widget-dnd > switch:checked {
        background: #44475a;
      }

      .widget-dnd > switch slider {
        background: #6272a4;
        border-radius: 8px;
        border: 1px solid #ffb86c;
      }
    '';
  };
}
