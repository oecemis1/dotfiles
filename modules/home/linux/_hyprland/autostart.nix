{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "waybar"
    "swaync-wrapper"
    "awww-daemon"
    "swayosd-server"
    "update-wallpaper.sh"
    "xremap"
  ];
}
