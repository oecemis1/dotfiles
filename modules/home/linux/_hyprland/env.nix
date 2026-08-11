{
  config,
  pkgs,
  lib,
  ...
}:
let
  lua = lib.generators.mkLuaInline;
  homeDir = config.home.homeDirectory;
  env = name: value: { _args = [ name value ]; };
in
{
  wayland.windowManager.hyprland.settings.env = [
    # Cursor Configuration
    (env "XCURSOR_SIZE" "30")
    (env "HYPRCURSOR_SIZE" "30")
    (env "XCURSOR_THEME" "Adwaita")

    # Desktop Environment
    (env "XDG_CURRENT_DESKTOP" "Hyprland")
    (env "XDG_SESSION_DESKTOP" "Hyprland")
    (env "XDG_SESSION_TYPE" "wayland")

    (env "XDG_DATA_HOME" "${homeDir}/.local/share")
    (env "XDG_CONFIG_HOME" "${homeDir}/.config")
    (env "XDG_STATE_HOME" "${homeDir}/.local/state")
    (env "XDG_CACHE_HOME" "${homeDir}/.cache")
    # One entry replaces the three prepending hyprlang lines; same final order.
    (env "PATH" (
      lua ''"/usr/local/bin:${homeDir}/.local/bin:${homeDir}/.local/share:${homeDir}/.config:${homeDir}/.local/state:${homeDir}/.cache:" .. os.getenv("PATH")''
    ))

    # GTK Theme Configuration
    (env "GTK_THEME" "Adwaita:dark")
    (env "GTK_APPLICATION_PREFER_DARK_THEME" "1")
    (env "GTK_USE_PORTAL" "1")

    # Qt Theme Configuration
    (env "QT_STYLE_OVERRIDE" "adwaita-dark")
    (env "QT_QPA_PLATFORMTHEME" "qt5ct")
    (env "QT_AUTO_SCREEN_SCALE_FACTOR" "1")
    (env "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1")
    (env "QT_QPA_PLATFORM" "wayland;xcb")

    # Application-Specific Settings
    (env "ELECTRON_OZONE_PLATFORM_HINT" "auto")
    (env "ELECTRON_FORCE_DARK_MODE" "1")
    (env "MOZ_ENABLE_WAYLAND" "1")
    (env "MOZ_WEBRENDER" "1")

    # Platform Backend Settings
    (env "GDK_BACKEND" "wayland,x11")
    (env "PREFER_DARK_THEME" "1")

    # Pin the compositor (and thus its clients' dmabuf device) to the iGPU.
    # Without this, aquamarine opens the NVIDIA card/render nodes too, which
    # holds the dGPU awake forever (runtime PM never re-enters D3cold, ~5W).
    # /dev/dri/igpu-card is a udev symlink (odyssey hardware.nix) - the
    # by-path name can't be used because AQ_DRM_DEVICES is colon-separated
    # and by-path names contain colons (Hyprland aborts: "Found no gpus").
    # PRIME offload (nvidia-offload <cmd>) still works. Caveat: external
    # outputs wired to the dGPU (its DP/HDMI connectors) won't light up
    # while this is set - remove it if an external display stays black.
    (env "AQ_DRM_DEVICES" "/dev/dri/igpu-card")
  ];
}
