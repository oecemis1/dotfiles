{ ... }:
{
  flake.modules.homeManager.cli =
    { ... }:
    {
      home.sessionVariables = {
        EDITOR = "hx";
        TERMINAL = "kitty";

        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_CACHE_HOME = "$HOME/.cache";
      };

      home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/docker-scripts"
      ];
    };
}
