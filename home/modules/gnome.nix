{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  wallpaper = pkgs.stdenv.mkDerivation {
    name = "wallpaper";
    src = ../../assets/wallpaper.jpg;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      cp $src $out/wallpaper.jpg;
    '';
  };

  # Enabled extensions
  extensions = with pkgs.gnomeExtensions; [
    # hide-top-bar
    dash-to-dock
  ];
  extension_UUID = map (extension: extension.extensionUuid) extensions;

in
{
  home.packages = extensions;

  # GNOME desktop settings via dconf
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      theme = "Yaru";
      num-workspaces = 2;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      tap-to-click = true;
    };

    "org/gnome/desktop/input-sources" = {
      show-all-sources = lib.mkDefault true;
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us"
        ])
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "tr"
        ])
      ];
      xkb-options = [ "grp:win_space_toggle" ];
    };

    # Window management shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      "close" = [ "<Alt>F4" ];
      "maximize" = [ "<Super>Up" ];
      "unmaximize" = [ "<Super>Down" ];
      "toggle-maximized" = [ "<Alt>F10" ];
      "minimize" = [ "<Super>h" ];
      "move-to-workspace-1" = [ "<Shift><Super>1" ];
      "move-to-workspace-2" = [ "<Shift><Super>2" ];
      "move-to-workspace-3" = [ "<Shift><Super>3" ];
      "move-to-workspace-4" = [ "<Shift><Super>4" ];
      "switch-to-workspace-1" = [ "<Super>1" ];
      "switch-to-workspace-2" = [ "<Super>2" ];
      "switch-to-workspace-3" = [ "<Super>3" ];
      "switch-to-workspace-4" = [ "<Super>4" ];
      "switch-windows" = [ "<Alt>Tab" ];
      "switch-applications" = [ "" ];
    };

    # Fixed custom keybindings section
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kitty";
      binding = "<Primary><Alt>t";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = extension_UUID;
      disable-overview-on-startup = true;
    };

    # GNOME Panel Visibility (via Hide Topbar)
    # "org/gnome/shell/extensions/hidetopbar" = {
    #   mouse-sensitive = false;
    #   shortcut-toggles = true;
    #   shortcut-keybind = ["<Super>k"];
    #   shortcut-delay = 0;
    #   animation-time-autohide = 0.1;
    #   animation-time-overview = 0.1;
    #   enable-intellihide = false;
    #   enable-active-window = false;
    #   pressure-threshold = 0;
    # };

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
      "disable-overview-on-startup" = true;
      "transparency-mode" = "DYNAMIC";
      "background-opacity" = 0.9;
      "dash-max-icon-size" = 44;
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
      "accent-color" = "purple";
      "icon-theme" = "Yaru";
      "gtk-theme" = "Yaru-magenta-dark";
      "color-scheme" = "prefer-dark";
      "monospace-font-name" = "JetBrains Mono 11";
      "font-name" = "SF Pro Display Regular 11";
      enable-hot-corners = false;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}/wallpaper.jpg";
      picture-uri-dark = "file://${wallpaper}/wallpaper.jpg";
      picture-options = "zoom";
    };

    # Set default terminal to kitty
    "org/gnome/desktop/applications/terminal" = {
      "exec" = "kitty";
    };

    "org/gnome/terminal/legacy/profiles:" = {
      default = ":b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
      list = [ ":b1dcc9dd-5262-4d8d-a863-c897e6d979b9" ];
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visible-name = "Default";
      background-color = "rgb(26,25,25)";
      background-transparency-percent = 6;
      font = "JetBrainsMono Nerd Font 11";
      foreground-color = "rgb(255,255,255)";
      palette = [
        "rgb(7,54,66)"
        "rgb(220,50,47)"
        "rgb(133,153,0)"
        "rgb(181,137,0)"
        "rgb(38,139,210)"
        "rgb(211,54,130)"
        "rgb(42,161,152)"
        "rgb(238,232,213)"
        "rgb(0,43,54)"
        "rgb(203,75,22)"
        "rgb(88,110,117)"
        "rgb(101,123,131)"
        "rgb(131,148,150)"
        "rgb(108,113,196)"
        "rgb(147,161,161)"
        "rgb(253,246,227)"
      ];
      use-system-font = false;
      use-theme-colors = false;
      use-theme-transparency = false;
      use-transparent-background = true;
    };
  };
}
