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
        before_sleep_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 180; # 3 minutes
          on-timeout = "pidof hyprlock || hyprlock";
        }
        {
          timeout = 240; # 4 minutes
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
