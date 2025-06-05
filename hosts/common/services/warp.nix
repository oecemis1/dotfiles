{
  pkgs,
  ...
}:
{
  services.cloudflare-warp = {
    enable = true;
    package = pkgs.cloudflare-warp;
  };
  systemd.user.services.warp-taskbar.wantedBy = [ "graphical.target" ];
}
