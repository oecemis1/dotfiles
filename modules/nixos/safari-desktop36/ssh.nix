{ ... }:
{
  flake.modules.nixos.safari-desktop36 =
    { ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ "orhun" ];
        };
      };

      users.users.orhun.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsaLROBXx8GmBfSFKaD7t4NLgmejMTOHQDwXJA222FJ oecemis-device0"
      ];
    };
}
