{ ... }:
{
  flake.modules.nixos.odyssey =
    { pkgs, ... }:
    {
      # environment.systemPackages = with pkgs; [virt-manager virtualbox distrobox];
      programs.virt-manager.enable = true;

      virtualisation.libvirtd = {
        enable = true;
        # ISSUE: https://discourse.nixos.org/t/virt-manager-cannot-find-virtiofsd/26752/9
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];

        qemu.verbatimConfig = ''
          group = "users"
          remember_owner = 0
        '';
      };
      environment.systemPackages = with pkgs; [
        virtiofsd
        docker-compose
      ];

      virtualisation.docker.enable = true;
    };
}
