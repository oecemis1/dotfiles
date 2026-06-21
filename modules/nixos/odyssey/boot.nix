{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    {
      systemd.services.pre-hibernate-disable-input-wake = {
        description = "Unbind pin controller before hibernate to prevent wake";
        before = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo INTC105E:00 > /sys/bus/platform/drivers/meteorlake-pinctrl/unbind'";
        };
      };

      systemd.services.post-hibernate-restore-input = {
        description = "Rebind pin controller after hibernate";
        after = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo INTC105E:00 > /sys/bus/platform/drivers/meteorlake-pinctrl/bind && ${pkgs.kmod}/bin/rmmod i2c_hid_acpi && ${pkgs.kmod}/bin/modprobe i2c_hid_acpi'";
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
        # dGPU resume-hang fix: the unbound NVIDIA dGPU (Integrated mode) can't return from
        # D3cold, stalling boot ~65s. Keep the PCIe port out of runtime PM.
        "pcie_port_pm=off"
        "resume_offset=13757716"
        "i915.enable_dpcd_backlight=1"
        "nvidia.NVreg_EnableBacklightHandler=0"
        "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
      ];

      services.fstrim.enable = true;
    };
}
