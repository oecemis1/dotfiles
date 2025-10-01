{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
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
        natural_scroll = false;
      };
    };
  };
}
