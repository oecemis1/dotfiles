{ ... }:
{
  flake.modules.nixos.safari-desktop36 =
    { ... }:
    {
      home-manager.users.orhun = {
        # 24" 1080p panel at scale 1: the shared 1.2 (homeManager.linux gnome.nix)
        # makes UI text too big here. Scales GTK apps and Firefox, not kitty.
        dconf.settings."org/gnome/desktop/interface"."text-scaling-factor" = 1.1;

        # kitty sizes its own font; picked up by the globinclude at the end
        # of .config/kitty/kitty.conf
        xdg.configFile."kitty/host.conf".text = ''
          font_size 12.0
        '';
      };
    };
}
