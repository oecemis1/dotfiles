{ ... }:
{
  flake.modules.nixos.odyssey =
    { config, lib, ... }:
    {
      options.odyssey.hybridGraphics = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run supergfxd in Hybrid mode (NVIDIA dGPU available) instead of Integrated.";
      };

      config = {
        services.supergfxd = {
          enable = true;
          settings = {
            mode = if config.odyssey.hybridGraphics then "Hybrid" else "Integrated";
            vfio_enable = false;
            vfio_save = false;
            always_reboot = false;
            no_logind = false;
            logout_timeout_s = 180;
            hotplug_type = "Asus";
          };
        };

        # dGPU resume-hang fix: the unbound NVIDIA dGPU (Integrated mode) can't return from
        # D3cold, stalling boot ~65s. Keep the PCIe port out of runtime PM. Integrated only —
        # in Hybrid mode this breaks the D3cold->D0 wake, leaving nvidia-smi with no devices.
        boot.kernelParams = lib.mkIf (!config.odyssey.hybridGraphics) [ "pcie_port_pm=off" ];

        # Default boot is Integrated (dGPU rail off, coolest/quietest); pick this
        # entry in GRUB when the 5070 Ti is needed. Integrated -> Hybrid needs a
        # FULL SHUTDOWN (not a warm reboot), or the dGPU stays stuck in D3cold.
        specialisation.hybrid-graphics.configuration.odyssey.hybridGraphics = true;

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
    };
}
