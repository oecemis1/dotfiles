{
  config,
  pkgs,
  lib,
  ...
}: {
  # GNOME desktop settings via dconf
  dconf.settings = {
    # Window management shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      "close" = ["<Alt>F4"];
      "maximize" = ["<Super>Up"];
      "unmaximize" = ["<Super>Down"];
      "toggle-maximized" = ["<Alt>F10"];
      "minimize" = ["<Super>h"];
      "move-to-workspace-1" = ["<Shift><Super>1"];
      "move-to-workspace-2" = ["<Shift><Super>2"];
      "move-to-workspace-3" = ["<Shift><Super>3"];
      "move-to-workspace-4" = ["<Shift><Super>4"];
      "switch-to-workspace-1" = ["<Super>1"];
      "switch-to-workspace-2" = ["<Super>2"];
      "switch-to-workspace-3" = ["<Super>3"];
      "switch-to-workspace-4" = ["<Super>4"];
      "switch-windows" = ["<Alt>Tab"];
      "switch-applications" = [""];
      "terminal" = ["<Primary><Alt>t"];
    };
    
    # Dash to dock settings
    "org/gnome/shell/extensions/dash-to-dock" = {
      "dock-position" = "BOTTOM";
      "dock-fixed" = false;
      "extend-height" = false;
      "isolate-workspaces" = false;
      "isolate-monitors" = false;
      "group-apps" = false;
      "show-apps-at-top" = true;
      "apply-custom-theme" = false;
      "custom-theme-shrink" = true;
      "transparency-mode" = "DYNAMIC";
      "background-opacity" = 0.8;
      "unity-backlit-items" = true;
      "click-action" = "minimize-or-previews";
      "intellihide-mode" = "ALL_WINDOWS";
      "require-pressure-to-show" = false;
      "show-trash" = false;
      "show-mounts" = false;
      "height-fraction" = 0.9;
    };
    
    # GNOME appearance settings
    "org/gnome/desktop/interface" = {
      "icon-theme" = "Yaru";
      "gtk-theme" = "Yaru-magenta-dark";
      "color-scheme" = "prefer-dark";
      "monospace-font-name" = "JetBrains Mono 11";
      "font-name" = "SF Pro Display Regular 11";
    };
    
    # Set default terminal to kitty
    "org/gnome/desktop/applications/terminal" = {
      "exec" = "kitty";
    };
    
    # Configure Nautilus to use kitty for the "Open in Terminal" action
    "org/gnome/nautilus/preferences" = {
      "terminal-executable" = "kitty";
    };
  };
}
