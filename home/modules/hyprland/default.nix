{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./autostart.nix
    ./env.nix
    ./input.nix
    ./waybar.nix
    ./swaync.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  home.packages = with pkgs; [
    hyprlock
    hyprpaper
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
}
