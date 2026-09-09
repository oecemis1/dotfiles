{
  config,
  inputs,
  pkgs,
  ...
}:
let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  launcher = pkgs.writeShellApplication {
    name = "quickshell-control-center";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
      quickshell
    ];
    text = ''
      instances=$(hyprctl instances -j)
      signature=$(jq -er 'max_by(.time).instance' <<<"$instances")
      display=$(jq -er 'max_by(.time).wl_socket' <<<"$instances")
      export HYPRLAND_INSTANCE_SIGNATURE="$signature"
      export WAYLAND_DISPLAY="$display"
      export QT_QPA_PLATFORM=wayland
      exec qs -p ${config.xdg.configHome}/quickshell
    '';
  };
in
{
  home.packages = [ quickshell ];

  systemd.user.services.quickshell-control-center = {
    Unit = {
      Description = "Quickshell control center";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      StartLimitIntervalSec = 0;
    };
    Service = {
      ExecStart = "${launcher}/bin/quickshell-control-center";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
