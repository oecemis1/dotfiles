{
  config,
  pkgs,
  lib,
  ...
}:
let
  colors = config.colorScheme.colors;
  swaync = pkgs.callPackage ../../../../pkgs/swaync.nix { };

  # Font sizes relative to the system font (dconf font-name x
  # text-scaling-factor), so notifications grow and shrink with it like
  # waybar and GTK apps; px would ignore the scaling. Arguments are px at
  # the 17.6px (11pt x 1.2) system font the design was tuned against.
  fontSize = px: "${toString (px / 17.6)}rem";

  glassStylesheet = pkgs.writeText "swaync-glass.css" ''
    @import url("file://${config.xdg.configHome}/swaync/style.css");

    .notification-glass-window,
    .control-center {
      background-color: transparent;
    }

    .notification-center-backdrop {
      background-color: rgba(0, 0, 0, 0.3137254901960784);
      border-radius: 24px;
    }

    .control-center {
      border-color: transparent;
      border-radius: 24px;
      margin: 0;
    }

    .floating-notifications.background .notification-row .notification-background {
      background-color: rgba(0, 0, 0, 0.3137254901960784);
      background-image: linear-gradient(
        to bottom,
        rgba(255, 255, 255, 0.05),
        rgba(255, 255, 255, 0) 42%,
        rgba(0, 0, 0, 0.12)
      );
      box-shadow:
        inset 0 1px 0 rgba(255, 255, 255, 0.16),
        0 1px 3px rgba(0, 0, 0, 0.3),
        0 4px 10px rgba(0, 0, 0, 0.3);
      border-color: transparent;
      border-radius: 24px;
      margin: 6px 16px 14px 20px;
    }

    .floating-notifications .notification-background .notification {
      border-radius: 24px;
    }

    .control-center .notification-row .notification-background {
      background-color: alpha(${colors.accent}, 0.0784313725490196);
      border-radius: 18px;
    }

    .control-center .notification-row .notification-background:hover {
      background-color: rgba(17, 17, 27, 0.2509803921568627);
    }

    .control-center .notification-background .notification {
      border-radius: 18px;
    }
  '';

  stylesheet = pkgs.writeText "swaync-style.css" ''
    /* Hand-owned copy of the generated swaync stylesheet, seeded once by
       home-manager and never clobbered (delete this file + rebuild to reseed
       from the flavor palette). Edit + `swaync-client --reload-css` to apply. */

    * {
      all: unset;
      font-size: ${fontSize 14};
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

    /* Action buttons: slim quiet chips, feedback on hover/press (like the bar) */
    .notification-background .notification .notification-alt-actions {
      margin: 0 4px 4px 4px;
    }

    .notification-background .notification .notification-action {
      background-color: alpha(${colors.text}, 0.06);
      border-radius: 10px;
      color: ${colors.text};
      margin: 0 3px;
      padding: 3px 10px;
    }

    .notification-background .notification .notification-action * {
      font-size: ${fontSize 13};
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
      font-size: ${fontSize 16};
      font-weight: 600;
    }

    .notification-background .notification .notification-content .time {
      color: ${colors.overlay};
    }

    .notification-background .notification .notification-content .body {
      color: ${colors.text};
      font-size: ${fontSize 16};
    }

    /* Icon sits left of the text; the app badge overlaps its corner */
    .notification-background .notification .notification-content .image {
      -gtk-icon-size: 40px;
      border-radius: 10px;
      margin-right: 12px;
    }

    .notification-background .notification .notification-content .app-icon {
      -gtk-icon-size: 16px;
      -gtk-icon-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
      margin-right: 8px;
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
in
{
  systemd.user.services.swaync = {
    Service = {
      ExecStart = lib.mkForce "${swaync}/bin/swaync -c ${config.xdg.configHome}/swaync/config.json -s ${glassStylesheet}";
      Environment = [
        "XDG_CONFIG_HOME=%h/.dummy"
      ];
      UnsetEnvironment = "GTK_THEME";
    };
  };

  home.activation.seedSwayncStyle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e "${config.xdg.configHome}/swaync/style.css" ] ||
      run install -Dm644 ${stylesheet} "${config.xdg.configHome}/swaync/style.css"
  '';

  services.swaync = {
    enable = true;
    package = swaync;

    settings = {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      # anchor the control center under the bell in the right module group;
      # toasts pop in the same column, where their card lands
      control-center-positionX = "right";
      layer = "overlay";
      control-center-layer = "overlay";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 49;
      control-center-margin-bottom = 4;
      control-center-margin-right = 4;
      control-center-margin-left = 10;
      notification-2fa-action = true;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      relative-timestamps = true;
      control-center-width = 462;
      control-center-height = -1;
      notification-window-width = 420;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      notification-action-filter = {
        browser-settings = {
          text-matcher = "Settings";
        };
      };
      notification-keep-on-close = {
        chrome = {
          app-name = "^Google Chrome$";
        };
      };
      # Widget transitions; the compositor handles the panel's fade.
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

      widgets = [ "notifications" ];

      widget-config = {
        notifications = {
          vexpand = false;
        };
      };
    };
  };
}
