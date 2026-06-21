# Composes the verbatim _hyprland/ config tree + its packages/services.
{ ... }:
{
  flake.modules.homeManager.linux =
    { pkgs, ... }:
    {
      imports = [
        ./_hyprland/hyprland.nix
        ./_hyprland/autostart.nix
        ./_hyprland/env.nix
        ./_hyprland/input.nix
        ./_hyprland/waybar.nix
        ./_hyprland/swaync.nix
        ./_hyprland/hyprlock.nix
        ./_hyprland/hypridle.nix
      ];

      home.packages = with pkgs; [
        hyprlock
        hyprshot
        waybar
        swaynotificationcenter
        swayosd

        grim
        slurp
        swappy
        kooha

        nwg-displays
        wlr-randr

        networkmanagerapplet
        brightnessctl
        udiskie
        yad
        pamix
        # moc
        pavucontrol
        dotool
        jq

        awww
        tofi

        adwaita-qt
        adwaita-qt6
      ];

      services.udiskie.enable = true;
      # https://github.com/nix-community/home-manager/issues/2064
      systemd.user.targets.tray.Unit.Requires = [ "graphical-session.target" ];
    };
}
