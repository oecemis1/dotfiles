{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
  };

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    vaapiVdpau
    libvdpau-va-gl
  ];

  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    intel-vaapi-driver
    vaapiVdpau
    libvdpau-va-gl
  ];
  
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
  };

  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  services.pulseaudio.support32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    # LIBVA_DRIVER_NAME = "nvidia";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
