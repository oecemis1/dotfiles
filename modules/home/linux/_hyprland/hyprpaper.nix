{ ... }:
{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;

      wallpaper = [
        {
          monitor = "*";
          path = "${../../../../assets/wallpaper.jpg}";
        }
      ];
    };
  };
}
