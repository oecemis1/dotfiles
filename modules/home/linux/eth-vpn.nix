{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, lib, ... }:
    let
      ethVpnTray = pkgs.callPackage ../../../pkgs/eth-vpn-tray.nix { };
    in
    {
      home.packages = [ ethVpnTray ];

      xdg.desktopEntries.eth-vpn = {
        name = "ETH VPN";
        comment = "Open the ETH student VPN tray controls";
        exec = lib.getExe ethVpnTray;
        icon = "network-vpn-symbolic";
        terminal = false;
        categories = [ "Network" ];
        startupNotify = false;
      };
    };
}
