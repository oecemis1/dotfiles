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
      # anchor the control center under the bell in the right module group
      # (toasts keep popping top-center via positionX above)
      control-center-positionX = "right";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 2;
      control-center-margin-bottom = 20;
      control-center-margin-right = 4;
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
      # panel reveal; matches the eww control center's 250ms slide. The
      # compositor's layer fade is disabled for this namespace so the
      # slide is the only motion.
      transition-time = 250;
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

      # dnd lives in the eww control center now
      widgets = [
        "inhibitors"
        "title"
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
        transition: background-color 120ms ease-out;
      }

      /* Toasts: heavier material than the bar — they float over content */
      .floating-notifications.background .notification-row .notification-background {
        background-color: alpha(${colors.base}, 0.8);
        border: 1px solid alpha(${colors.surface1}, 0.6);
        border-radius: 6px;
        margin: 8px;
        padding: 0;
        color: ${colors.text};
      }

      /* Control center: the same blurred material as the bar */
      .control-center {
        background-color: alpha(${colors.base}, 0.65);
        border: 1px solid alpha(${colors.surface1}, 0.6);
        border-radius: 6px;
        margin: 4px;
        padding: 12px;
        color: ${colors.text};
      }

      /* Header hierarchy borrows the calendar's two-tone warmth:
         accent title, accent2 secondary label */
      .control-center .widget-title {
        color: ${colors.accent};
        font-weight: 600;
        font-size: 1.1em;
        margin-bottom: 8px;
      }

      /* Clear All: accent-tinted chip */
      .control-center .widget-title button {
        background-color: alpha(${colors.accent}, 0.12);
        border-radius: 4px;
        color: ${colors.accent};
        padding: 6px 10px;
      }

      .control-center .widget-title button:hover {
        background-color: alpha(${colors.accent}, 0.2);
      }

      .control-center .widget-title button:active {
        background-color: ${colors.accent};
        color: ${colors.crust};
      }

      /* Action buttons: quiet chips, feedback on hover/press (like the bar) */
      .notification-background .notification .notification-action {
        background-color: alpha(${colors.text}, 0.06);
        border-radius: 4px;
        color: ${colors.text};
        padding: 6px 10px;
      }

      .notification-background .notification .notification-action:hover {
        background-color: alpha(${colors.text}, 0.12);
      }

      .notification-background .notification .notification-action:active {
        background-color: alpha(${colors.text}, 0.16);
      }

      /* Notification cards */
      .notification-background .notification {
        padding: 7px;
        border-radius: 6px;
      }

      .notification-background .notification .notification-content {
        margin: 7px;
      }

      .notification-background .notification .notification-content .summary {
        color: ${colors.accent2};
        font-weight: 600;
      }

      .notification-background .notification .notification-content .time {
        color: ${colors.overlay};
      }

      .notification-background .notification .notification-content .body {
        color: ${colors.text};
      }

      .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      /* Cards inside the control center: a raised surface. Must be OPAQUE:
         same-app notifications collapse into an offset stack, and the front
         card masks the ones behind it only if its background is solid. */
      .control-center .notification-row .notification-background {
        background-color: ${colors.surface0};
        border-radius: 6px;
        margin-top: 10px;
        color: ${colors.text};
      }

      .control-center .notification-row .notification-background:hover {
        background-color: ${colors.surface1};
      }

      /* Close: quiet until hovered — red is for the destructive moment */
      .notification-background .close-button {
        background-color: alpha(${colors.text}, 0.06);
        color: ${colors.text};
        border-radius: 4px;
        margin: 7px;
        padding: 2px;
      }

      .notification-background .close-button:hover {
        background-color: ${colors.red};
        color: ${colors.crust};
      }

      /* Progress */
      progressbar,
      progress,
      trough {
        border-radius: 4px;
      }

      trough {
        background-color: alpha(${colors.text}, 0.1);
      }

      .notification.critical progress {
        background-color: ${colors.red};
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: ${colors.accent};
      }

    '';
  };
}
