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
    ./hyprlock.nix
  ];

  home.packages = with pkgs; [
    hyprlock
    hyprpaper
    hypridle
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
    yad
    pamix
    # moc
    pavucontrol
    dotool
    jq

    swww
    tofi
  ];
}
