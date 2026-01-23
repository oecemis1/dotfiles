{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        grace = 5;
      };

      background = [
        {
          monitor = "";
          path = "$HOME/.config/wallpapers/wallpaper.jpg";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 3;
          dots_size = 0.2;
          dots_spacing = 0.64;
          dots_center = true;
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          position = "0, 65";
          halign = "center";
          valign = "bottom";
        }
      ];

      label = [
        # Current time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b><big> $(date +"%H:%M:%S") </big></b>"'';
          font_size = 94;
          font_family = "SF Pro Display 10";
          position = "0, 0";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 4;
        }
        # User label
        {
          monitor = "";
          # text = ''Hey <span text_transform="capitalize" size="larger">$USER</span>'';
          text = "";
          font_size = 20;
          font_family = "SF Pro Display 10";
          position = "0, -80";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 4;
        }
        # Type to unlock
        {
          monitor = "";
          text = "Type to unlock";
          font_size = 20;
          font_family = "SF Pro Display 10";
          position = "0, 30";
          halign = "center";
          valign = "bottom";
          shadow_passes = 3;
          shadow_size = 4;
        }
      ];
    };
  };
}
