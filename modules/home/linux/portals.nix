{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config = {
          common = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
            "org.freedesktop.impl.portal.GlobalShortcuts" = [ "hyprland" ];
            # "org.freedesktop.impl.portal.FileChooser" = [
            #   "termfilechooser"
            # ]; # not working
          };
          hyprland = {
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-termfilechooser
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
    };
}
