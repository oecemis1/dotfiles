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
        font-family: "SF Pro Display";
        transition: 200ms;
      }

      .floating-notifications.background .notification-row .notification-background {
        border-radius: 12.6px;
        margin: 18px;
        background-color: ${colors.base};
        color: ${colors.text};
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
        color: ${colors.text};
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
        color: ${colors.accent2};
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
        color: ${colors.text};
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: ${colors.text};
        background-color: ${colors.surface0};
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: ${colors.overlay};
        color: ${colors.text};
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: ${colors.accent};
        color: ${colors.text};
      }

      .floating-notifications.background .notification-row .notification-background .close-button {
        margin: 7px;
        padding: 2px;
        border-radius: 6.3px;
        color: ${colors.base};
        background-color: ${colors.red};
      }

      .floating-notifications.background .notification-row .notification-background .close-button:hover {
        background-color: ${colors.text};
        color: ${colors.base};
      }

      .floating-notifications.background .notification-row .notification-background .close-button:active {
        background-color: ${colors.red};
        color: ${colors.base};
      }

      .control-center {
        border-radius: 12.6px;
        margin: 18px;
        background-color: ${colors.base};
        color: ${colors.text};
        padding: 14px;
        opacity: 0.8;
        max-height: calc(100vh - 60px);
        overflow-y: auto;
      }

      .control-center .widget-title {
        color: ${colors.text};
        font-size: 1.3em;
      }

      .control-center .widget-title button {
        border-radius: 7px;
        color: ${colors.text};
        background-color: ${colors.surface0};
        padding: 8px;
      }

      .control-center .widget-title button:hover {
        background-color: ${colors.green};
        color: ${colors.base};
      }

      .control-center .widget-title button:active {
        background-color: ${colors.accent};
        color: ${colors.base};
      }

      .control-center .notification-row .notification-background {
        border-radius: 7px;
        color: ${colors.text};
        background-color: ${colors.surface0};
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
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background .notification .notification-content .time {
        color: ${colors.accent2};
      }

      .control-center .notification-row .notification-background .notification .notification-content .body {
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: ${colors.text};
        background-color: ${colors.overlay};
        margin: 7px;
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        background-color: ${colors.surface0};
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        background-color: ${colors.accent};
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background .close-button {
        margin: 7px;
        padding: 2px;
        border-radius: 6.3px;
        color: ${colors.base};
        background-color: ${colors.text};
      }

      .control-center .notification-row .notification-background .close-button:hover {
        background-color: ${colors.red};
        color: ${colors.base};
      }

      .control-center .notification-row .notification-background .close-button:active {
        background-color: ${colors.red};
        color: ${colors.base};
      }

      .control-center .notification-row .notification-background:hover {
        background-color: ${colors.overlay};
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background:active {
        background-color: ${colors.accent};
        color: ${colors.text};
      }

      progressbar,
      progress,
      trough {
        border-radius: 12.6px;
      }

      .notification.critical progress {
        background-color: ${colors.red};
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: ${colors.accent};
      }

      trough {
        background-color: ${colors.surface0};
      }

      .control-center trough {
        background-color: ${colors.overlay};
      }

      .control-center-dnd {
        margin-top: 5px;
        border-radius: 8px;
        background: ${colors.surface0};
        border: 1px solid ${colors.overlay};
      }

      .control-center-dnd:checked {
        background: ${colors.surface0};
      }

      .control-center-dnd slider {
        background: ${colors.overlay};
        border-radius: 8px;
      }

      .widget-dnd {
        margin: 0px;
        font-size: 1.1rem;
      }

      .widget-dnd > switch {
        font-size: initial;
        border-radius: 8px;
        background: ${colors.surface0};
        border: 1px solid ${colors.overlay};
      }

      .widget-dnd > switch:checked {
        background: ${colors.surface0};
      }

      .widget-dnd > switch slider {
        background: ${colors.overlay};
        border-radius: 8px;
        border: 1px solid ${colors.orange};
      }
    '';
  };
}
