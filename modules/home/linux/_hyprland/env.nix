{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings =
    let
      homeDir = config.home.homeDirectory;
    in
    {
      env = [
        # Cursor Configuration
        "XCURSOR_SIZE,30"
        "HYPRCURSOR_SIZE,30"
        "XCURSOR_THEME,Adwaita"

        # Desktop Environment
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"

        "XDG_DATA_HOME,${homeDir}/.local/share"
        "XDG_CONFIG_HOME,${homeDir}/.config"
        "XDG_STATE_HOME,${homeDir}/.local/state"
        "XDG_CACHE_HOME,${homeDir}/.cache"
        "PATH,${homeDir}/.local/share:${homeDir}/.config:${homeDir}/.local/state:${homeDir}/.cache:$PATH"
        "PATH,${homeDir}/.local/bin:$PATH"
        "PATH,/usr/local/bin:$PATH"

        # GTK Theme Configuration
        "GTK_THEME,Adwaita:dark"
        "GTK_APPLICATION_PREFER_DARK_THEME,1"
        "GTK_USE_PORTAL,1"

        # Qt Theme Configuration
        "QT_STYLE_OVERRIDE,adwaita-dark"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland;xcb"

        # Application-Specific Settings
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "ELECTRON_FORCE_DARK_MODE,1"
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_WEBRENDER,1"

        # Platform Backend Settings
        "GDK_BACKEND,wayland,x11"
        "PREFER_DARK_THEME,1"

        # Pin the compositor (and thus its clients' dmabuf device) to the iGPU.
        # Without this, aquamarine opens the NVIDIA card/render nodes too, which
        # holds the dGPU awake forever (runtime PM never re-enters D3cold, ~5W).
        # /dev/dri/igpu-card is a udev symlink (odyssey hardware.nix) - the
        # by-path name can't be used because AQ_DRM_DEVICES is colon-separated
        # and by-path names contain colons (Hyprland aborts: "Found no gpus").
        # PRIME offload (nvidia-offload <cmd>) still works. Caveat: external
        # outputs wired to the dGPU (its DP/HDMI connectors) won't light up
        # while this is set - remove it if an external display stays black.
        "AQ_DRM_DEVICES,/dev/dri/igpu-card"
      ];
    };
}
