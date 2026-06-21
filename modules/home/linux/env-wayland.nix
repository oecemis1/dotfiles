{ ... }:
{
  flake.modules.homeManager.linux =
    { ... }:
    {
      home.sessionVariables = {
        OPENER = "xdg-open";
        QT_QPA_PLATFORM = "wayland;xcb";
        WLR_NO_HARDWARE_CURSORS = "1";
        NIXOS_OZONE_WL = "1";
      };
    };
}
