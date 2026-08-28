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
      # The two CS35L56 speaker amps share one reset GPIO and one interrupt
      # pad. The second amp (cs35l56-hda.1, owns neither) wedges when
      # suspended in place across hibernate ("Firmware boot timed out ...
      # Hibernate wake failed", right woofer silent; kernel bugzilla #221161
      # is the same bug on the cs35l41). Unloading the whole driver before
      # sleep doesn't work either: with no owner at freeze time the Intel
      # pinctrl doesn't save/restore the shared IRQ pad, and re-probe dies
      # with request_irq -EIO. So unbind ONLY amp .1 before sleep and rebind
      # it after: amp .0 (which has never failed to resume) keeps the IRQ pad
      # owned across sleep and its resume pulses the shared reset, leaving .1
      # freshly reset for a boot-equivalent probe.
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
            # PipeWire holds the ALSA device open across sleep, so nothing
            # re-prepares the stream and the rebound amp doesn't get its
            # AUDIO_PLAY until the sink idles and reopens - the woofers stay
            # silent for a while. Cycling the sink forces the reopen now.
            "${pkgs.util-linux}/bin/runuser -u orhun -- ${pkgs.bash}/bin/bash -c 'export XDG_RUNTIME_DIR=/run/user/1000; ${pkgs.pulseaudio}/bin/pactl suspend-sink @DEFAULT_SINK@ 1; sleep 0.5; ${pkgs.pulseaudio}/bin/pactl suspend-sink @DEFAULT_SINK@ 0; exit 0'"
          ];
        };
      };
    };
}
