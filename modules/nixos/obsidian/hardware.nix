{ ... }:
{
  flake.modules.nixos.obsidian =
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
      # hardware.amdgpu.amdvlk = {
      #   enable = false;
      #   support32Bit = true;
      # };

      services.xserver.videoDrivers = lib.mkDefault [
        "modesetting"
      ];

      environment.variables = {
        VDPAU_DRIVER = "radeonsi";
        LIBVA_DRIVER_NAME = "radeonsi";
      };
    };
}
