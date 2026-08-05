{ ... }:
{
  flake.modules.nixos.odyssey =
    { config, ... }:
    {
      services.supergfxd.enable = true;
      specialisation = {
        integrated-graphics.configuration = {
          # dGPU resume-hang fix: the unbound NVIDIA dGPU (Integrated mode) can't return from
          # D3cold, stalling boot ~65s. Keep the PCIe port out of runtime PM. Only here — in
          # Hybrid mode this breaks the D3cold->D0 wake, leaving nvidia-smi with no devices.
          boot.kernelParams = [ "pcie_port_pm=off" ];
          services.supergfxd = {
            enable = true;
            settings = {
              mode = "Integrated";
              vfio_enable = false;
              vfio_save = false;
              always_reboot = false;
              no_logind = false;
              logout_timeout_s = 180;
              hotplug_type = "Asus";
            };
          };
        };
        # hybrid-graphics.configuration = {
        #   services.supergfxd.settings = {
        #     mode = "Hybrid";
        #   };
        # };
      };

      services.asusd = {
        enable = true;
        # enableUserService = true;
        fanCurvesConfig.source = ./fan_curves.ron;
        asusdConfig.source = ./asusd.ron;
      };

      systemd.services.asusd = {
        restartTriggers = [ config.services.asusd.fanCurvesConfig.source ];
      };
      programs.rog-control-center.enable = true;
    };
}
