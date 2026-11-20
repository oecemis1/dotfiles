{ ... }:
{
  flake.modules.nixos.core =
    { lib, pkgs, ... }:
    let
      ethVpn = pkgs.writeShellApplication {
        name = "eth-vpn";
        text = ''
          if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
            echo "Usage: eth-vpn <ETH-login>" >&2
            exit 1
          fi

          exec sudo ${lib.getExe pkgs.openconnect} \
            --user="$1@student-net.ethz.ch" \
            --useragent=AnyConnect \
            --authgroup=student-net \
            --no-external-auth \
            sslvpn.ethz.ch
        '';
      };
    in
    {
      networking.networkmanager = {
        enable = true;
        plugins = [ pkgs.networkmanager-openconnect ];
        ensureProfiles.profiles.eth-student = {
          connection = {
            id = "ETH Student VPN";
            uuid = "c10d378b-595a-55d8-8c10-1db7e9b6a2c9";
            type = "vpn";
            autoconnect = false;
          };
          vpn = {
            service-type = "org.freedesktop.NetworkManager.openconnect";
            gateway = "sslvpn.ethz.ch/student-net";
            protocol = "anyconnect";
            useragent = "AnyConnect";
            prevent_invalid_cert = "yes";
            cookie-flags = 2;
            gateway-flags = 2;
            gwcert-flags = 2;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };

      environment.systemPackages = [
        pkgs.openconnect
        ethVpn
      ];

      systemd.services.NetworkManager-wait-online.enable = false;
      systemd.network.wait-online.enable = false;
    };
}
