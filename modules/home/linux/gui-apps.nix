{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Browser, media, torrents
        google-chrome
        spotify
        qbittorrent

        qalculate-qt

        # Wayland / X11 tooling
        ueberzugpp
        wl-clipboard
        wl-clip-persist
        dragon-drop
        xsel
        xremap

        # Hardware / system
        cpufrequtils
        mesa-demos
        pciutils
        gnome-power-manager

        xhost
        xauth

        imhex
        eww
      ];
    };
}
