{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    let
      # Native Wayland + VA-API hardware video decode
      chrome = pkgs.google-chrome.override {
        commandLineArgs = [
          "--ozone-platform=wayland"
          "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,AcceleratedVideoDecodeLinuxGL,WaylandWindowDecorations"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
      };
    in
    {
      home.packages = with pkgs; [
        # Browser, media, torrents
        chrome
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
      ];

      xdg.configFile."google-patent-cli/config.toml".text = ''
        browser_path = "${chrome}/bin/google-chrome-stable"
      '';
    };
}
