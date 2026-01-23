_: rec {
  # Bash environment variables and functions
  home.sessionVariables = {
    EDITOR = "hx";
    TERMINAL = "kitty";
    OPENER = "xdg-open";

    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";

    QT_QPA_PLATFORM = "wayland;xcb";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/docker-scripts"
  ];
}
