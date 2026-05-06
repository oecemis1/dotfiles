{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "nm-applet &"
    "waybar"
    "swaync-wrapper"
    "swww-daemon"
    "swayosd-server"
    "update-wallpaper.sh"
    "xremap"
    "blueman-applet"
  ];
}
