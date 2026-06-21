{ ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        profiles.default.userSettings = {
          "workbench.colorTheme" = "Dracula Theme";
          "workbench.colorCustomizations" = {
            "editor.background" = "#15161d";
          };
          "editor.fontFamily" = "'MonaspiceNe Nerd Font Mono','Droid Sans Mono', 'monospace', monospace";
          "editor.fontLigatures" = "'calt','liga','ss07','ss08'";
          "editor.fontWeight" = "500";
          "editor.fontSize" = 14;
          "window.zoomLevel" = 0.5;
          "terminal.integrated.defaultProfile.linux" = "bash";
          "terminal.integrated.profiles.linux" = {
            "bash" = {
              "path" = "${pkgs.bash}/bin/bash";
              "icon" = "terminal-bash";
              "args" = [ "--login" ];
            };
          };
          "terminal.integrated.cwd" = null;
          "terminal.integrated.inheritEnv" = true;
          "terminal.integrated.fontSize" = 14;
        };
      };
    };
}
