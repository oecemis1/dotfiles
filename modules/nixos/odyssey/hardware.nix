{ ... }:
{
  flake.modules.nixos.odyssey =
    { config, pkgs, ... }:
    {
      imports = [ ./_hardware-configuration.nix ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          # intel-vaapi-driver
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };

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
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      services.pulseaudio.support32Bit = true;
      services.xserver.videoDrivers = [
        "nvidia"
        "intel"
      ];

      environment.variables = {
        LIBVA_DRIVER_NAME = "iHD";
        # LIBVA_DRIVER_NAME = "nvidia";
        # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
}
