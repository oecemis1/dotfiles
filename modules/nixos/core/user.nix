{ ... }:
{
  flake.modules.nixos.core =
    { ... }:
    {
      users.users.orhun = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
          "networkmanager"
          "wheel"
          "audio"
          "video"
          "input"
          "uinput"
          "libvirtd"
          "docker"
        ];
        linger = true;
      };
    };
}
