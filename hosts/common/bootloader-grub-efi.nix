{
  lib,
  canTouchEfiVariables ? false,
  useOSProber ? true,
  ...
}:
{
  boot.loader = {
    grub = {
      enable = lib.mkDefault true;
      device = "nodev";
      efiSupport = true;
      inherit  useOSProber;
      default = "saved";
      configurationLimit = 30;
    };
    efi.canTouchEfiVariables = canTouchEfiVariables;
  };
}
