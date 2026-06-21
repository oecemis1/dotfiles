{ ... }:
{
  flake.modules.nixos.odyssey =
    { config, ... }:
    {
      services.supergfxd.enable = true;
      specialisation = {
        integrated-graphics.configuration = {
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
