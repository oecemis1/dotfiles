{
  pkgs, # pkgs is needed for dracula-theme and dracula-icon-theme
  config, # config is generally useful to have
  lib, # lib is generally useful to have
  ...
}:

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
      # package = pkgs.yaru-theme;
      # name = "Yaru-magenta-dark";
    };
    iconTheme = {
      package = pkgs.dracula-icon-theme;
      name = "Dracula";
      # package = pkgs.yaru-theme;
      # name = "Yaru";
    };
    cursorTheme = {
      package = pkgs.dracula-theme;
      name = "Dracula-cursors";
      size = 10;
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
}
