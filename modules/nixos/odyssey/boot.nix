{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    let
      trackpad = "i2c-ASUF1209:00";
    in
    {
      systemd.services.pre-hibernate-disable-input-wake = {
        description = "Disarm trackpad wake source before hibernate to prevent abort-on-contact";
        before = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo disabled > /sys/bus/i2c/devices/${trackpad}/power/wakeup'";
        };
      };

      systemd.services.post-hibernate-restore-input = {
        description = "Re-probe trackpad and re-arm its wake source after hibernate";
        after = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.bash}/bin/bash -c 'echo ${trackpad} > /sys/bus/i2c/drivers/i2c_hid_acpi/unbind || true'"
            "${pkgs.bash}/bin/bash -c 'echo ${trackpad} > /sys/bus/i2c/drivers/i2c_hid_acpi/bind'"
            "${pkgs.bash}/bin/bash -c 'echo enabled > /sys/bus/i2c/devices/${trackpad}/power/wakeup'"
          ];
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
