{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us,tr";
      kb_variant = "";
      kb_model = "";
      kb_options = "grp:win_space_toggle";
      kb_rules = "";
      follow_mouse = 1;
      sensitivity = 0;
      numlock_by_default = true;
      repeat_rate = 30;
      repeat_delay = 200;
      mouse_refocus = true;
      float_switch_override_focus = 1;
      accel_profile = "flat";

      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
        scroll_factor = 0.1;
      };
    };
  };
}
