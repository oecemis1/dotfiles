{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Runs once at compositor startup (not on config reload) — the lua
  # equivalent of the old exec-once list.
  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("waybar")
            hl.exec_cmd("eww-ensure-daemon")
            hl.exec_cmd("swaync-wrapper")
            hl.exec_cmd("awww-daemon")
            hl.exec_cmd("swayosd-server")
            hl.exec_cmd("update-wallpaper.sh")
            hl.exec_cmd("xremap")
          end'')
      ];
    }
  ];
}
