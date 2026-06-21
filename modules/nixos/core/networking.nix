{ ... }:
{
  flake.modules.nixos.core =
    { ... }:
    {
      networking.networkmanager.enable = true;
      systemd.services.NetworkManager-wait-online.enable = false;
      systemd.network.wait-online.enable = false;
    };
}
