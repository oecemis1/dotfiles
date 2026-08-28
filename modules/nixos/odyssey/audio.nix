{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    let
      sleepServices = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
        "systemd-suspend-then-hibernate.service"
      ];
    in
    {
      systemd.services.pre-sleep-unbind-cs35l56-amp2 = {
        description = "Unbind second CS35L56 amp before sleep to avoid wedging it";
        before = sleepServices;
        wantedBy = sleepServices;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo spi1-CSC3556:00-cs35l56-hda.1 > /sys/bus/spi/drivers/cs35l56-hda/unbind || true'";
        };
      };

      systemd.services.post-sleep-rebind-cs35l56-amp2 = {
        description = "Re-probe second CS35L56 amp after sleep";
        after = sleepServices;
        wantedBy = sleepServices;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.bash}/bin/bash -c 'echo spi1-CSC3556:00-cs35l56-hda.1 > /sys/bus/spi/drivers/cs35l56-hda/bind'"
            "${pkgs.util-linux}/bin/runuser -u orhun -- ${pkgs.bash}/bin/bash -c 'export XDG_RUNTIME_DIR=/run/user/1000; ${pkgs.pulseaudio}/bin/pactl suspend-sink @DEFAULT_SINK@ 1; sleep 0.5; ${pkgs.pulseaudio}/bin/pactl suspend-sink @DEFAULT_SINK@ 0; exit 0'"
          ];
        };
      };
    };
}
