{ ... }:
{
  flake.modules.nixos.core =
    { lib, ... }:
    {
      boot.loader = {
        grub = {
          enable = lib.mkDefault true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
          default = "saved";
          configurationLimit = 30;
        };
        efi.canTouchEfiVariables = true;
      };
    };
}
