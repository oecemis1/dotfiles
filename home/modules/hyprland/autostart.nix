{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "nm-applet &"
    "hyprpaper"
    "waybar"
    "swaync-wrapper"
    "swww-daemon"
    "swayosd-server"
    "update-wallpaper.sh"
    "xremap"
  ];
}
