{ ... }:
{
  flake.modules.nixos.oe-desktop00 =
    { lib, ... }:
    {
      imports = [ ./_hardware-configuration.nix ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = lib.mkDefault [
        "modesetting"
      ];
    };
}
