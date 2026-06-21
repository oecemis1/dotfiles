{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    {
      time.timeZone = "Europe/Zurich";
      nix.settings = {
        max-jobs = 16;
        cores = 16;
      };

      services.mullvad-vpn.enable = true;
      programs.wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
      users.users.orhun.extraGroups = [ "wireshark" ];

      systemd.user.services.tmux.serviceConfig.TimeoutStopSec = "5s";

      environment.systemPackages = [ pkgs.linuxPackages.turbostat ];

      fonts.packages = [
        (pkgs.stdenv.mkDerivation {
          name = "sf-mono-fonts";
          src = ../../../.config/fonts/sf-mono;
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            cp -r ./*.otf $out/share/fonts/opentype/
          '';
        })
      ];
    };
}
