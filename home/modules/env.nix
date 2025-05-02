_: rec {
  # Bash environment variables and functions
  home.sessionVariables = {
    EDITOR = "hx";
    TERMINAL = "kitty";
    TERM = "kitty";
    OPENER = "xdg-open";
    
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };    

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
