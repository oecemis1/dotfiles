{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 120;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        {
          timeout = 121;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Uncomment if you want suspend after 9 minutes
        # {
        #   timeout = 540;  # 9 minutes
        #   on-timeout = "systemctl suspend";
        # }
      ];
    };
  };
}
