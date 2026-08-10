{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Browser, media, torrents
        # Native Wayland + VA-API hardware video decode
        (google-chrome.override {
          commandLineArgs = [
            "--ozone-platform=wayland"
            "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,AcceleratedVideoDecodeLinuxGL,WaylandWindowDecorations"
            "--ignore-gpu-blocklist"
            "--enable-zero-copy"
          ];
        })
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
