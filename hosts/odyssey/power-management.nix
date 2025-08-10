_: {

  powerManagement = {
    enable = true;
    powertop.enable = true;
    # cpuFreqGovernor = "schedutil";
    cpuFreqGovernor = "powersave";
  };

  services.acpid.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = false;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      PLATFORM_PROFILE_ON_AC = "default";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Kernel NMI watchdog
      NMI_WATCHDOG = 0;

      # USB autosuspend
      USB_AUTOSUSPEND = 1;

      # Battery care settings
      START_CHARGE_THRESH_BAT0 = 70; # Start charging when below 40%
      STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging at 80%
    };
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
