{ ... }:
{
  flake.modules.nixos.odyssey =
    { ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };
    };
}
