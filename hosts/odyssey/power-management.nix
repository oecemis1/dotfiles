_: {

  powerManagement = {
    enable = true;
    powertop.enable = true;
    # cpuFreqGovernor = "schedutil";
    cpuFreqGovernor = "powersave";
  };

  # services.acpid.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      CPU_SCALING_MAX_FREQ_ON_BAT = 1000000;

      CPU_BOOST_ON_BAT = 0;
      CPU_BOOST_ON_AC = 1;

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "quiet";

      # Battery care settings
      START_CHARGE_THRESH_BAT0 = 70; # Start charging when below 40%
      STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging at 80%
    };
  };

}
