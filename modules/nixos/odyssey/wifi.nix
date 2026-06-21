# rtl8851bu USB Wi-Fi driver — UNWIRED (opt-in; add odysseyWifi to the host to enable).
{ ... }:
{
  flake.modules.nixos.odysseyWifi =
    { config, pkgs, ... }:
    {
      services.udev.extraRules = ''
        ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 0bda -p 1a2b -V 0bda -P b851 -K"
      '';
      boot.kernelModules = [ "8851bu" ];
      boot.extraModulePackages = [
        (config.boot.kernelPackages.callPackage ../../../pkgs/rtl8851bu.nix {
          kernel = config.boot.kernelPackages.kernel;
          kernelModuleMakeFlags = config.boot.kernelPackages.kernelModuleMakeFlags;
        })
      ];
    };
}
