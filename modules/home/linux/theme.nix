{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dracula-theme
        dracula-icon-theme
      ];

      gtk = {
        enable = true;
        theme = {
          package = pkgs.dracula-theme;
          name = "Dracula";
        };
        iconTheme = {
          package = pkgs.dracula-icon-theme;
          name = "Dracula";
        };
        cursorTheme = {
          package = pkgs.dracula-theme;
          name = "Dracula-cursors";
          size = 25;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk";
      };

      home.pointerCursor = {
        gtk.enable = true;
        name = "Dracula-cursors";
        package = pkgs.dracula-theme;
        size = 10;
      };
    };
}
