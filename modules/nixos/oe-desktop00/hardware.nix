{ ... }:
{
  flake.modules.nixos.oe-desktop00 =
    { lib, pkgs, ... }:
    {
      imports = [ ./_hardware-configuration.nix ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
        ];
      };

      hardware.amdgpu.initrd.enable = true;
      hardware.amdgpu.opencl.enable = true;

      services.xserver.videoDrivers = lib.mkDefault [
        "modesetting"
      ];

      environment.variables = {
        VDPAU_DRIVER = "radeonsi";
        LIBVA_DRIVER_NAME = "radeonsi";
      };
    };
}
