{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    {
      # Trackpad contact during hibernate entry aborts the hibernation, so its
      # wake source is disarmed around hibernate. Done via the device's wakeup
      # toggle — NOT by unbinding the INTC105E pin controller: that controller
      # also provides the CS35L56 amps' reset GPIO, interrupt, and SPI chip
      # select, and bouncing it leaves those dangling until reboot (amp
      # re-probe then fails with request_irq -EINVAL / firmware boot timeout).
      systemd.services.pre-hibernate-disable-input-wake = {
        description = "Disarm trackpad wake source before hibernate to prevent abort-on-contact";
        before = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo disabled > /sys/bus/i2c/devices/i2c-ASUF1209:00/power/wakeup'";
        };
      };

      systemd.services.post-hibernate-restore-input = {
        description = "Re-arm trackpad wake source after hibernate";
        after = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo enabled > /sys/bus/i2c/devices/i2c-ASUF1209:00/power/wakeup'";
        };
      };

      # The eww daemon can wedge across hibernate with the control center's
      # fullscreen click-catcher still mapped, turning every screen click
      # into "open the panel". Restart it clean after any sleep; windows are
      # all transient popups, so nothing user-visible is lost.
      systemd.services.post-sleep-restart-eww = {
        description = "Restart the eww daemon after sleep";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-suspend-then-hibernate.service"
        ];
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-suspend-then-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.util-linux}/bin/runuser -u orhun -- ${pkgs.writeShellScript "restart-eww" ''
            export HOME=/home/orhun
            export XDG_RUNTIME_DIR=/run/user/1000
            export WAYLAND_DISPLAY=wayland-1
            export PATH=/home/orhun/.local/bin:/home/orhun/.nix-profile/bin:$PATH
            pkill -u orhun -f 'eww open' || true
            eww kill 2>/dev/null || true
            pkill -u orhun -f 'eww daemon' || true
            sleep 0.3
            ${pkgs.util-linux}/bin/setsid -f eww-ensure-daemon
            exit 0
          ''}";
        };
      };

      boot.kernelParams = [
        "intel_pstate"
        "intel_idle.max_cstate=99"
        "processor.max_cstate=99"
        "ahci.mobile_lpm_policy=3"
        "pcie_aspm=force"
        "pcie_aspm.policy=powersupersave"
        # "intel_pstate=no_hwp"
        "resume_offset=13757716"
        "i915.enable_dpcd_backlight=1"
        "nvidia.NVreg_EnableBacklightHandler=0"
        "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
      ];

      services.fstrim.enable = true;
    };
}
