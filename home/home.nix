{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  username = "orhun";
in
{
  # Home Manager needs to know which is the home directory and username
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Import modules
  imports = [
    (import ./xdg.nix {
      inherit pkgs inputs config;
      dotfilesDir = "/home/${username}/Documents/dotfiles";
    })
    ../pkgs/low_battery_notify.nix
    ./modules/shell.nix
    ./modules/gnome.nix
    ./modules/env.nix
    ./modules/hyprland
    ./modules/theme.nix
  ];

  home.packages = with pkgs; [
    # Browser
    google-chrome
    spotify
    qbittorrent

    # Development tools
    tmux
    helix
    # (pkgs.callPackage ../pkgs/helix.nix { })
    neovim
    direnv
    qalculate-qt
    libqalculate

    # Terminal tools
    kitty
    btop
    yazi
    ueberzugpp
    wl-clipboard
    wl-clip-persist
    xdragon
    ripgrep
    yek
    xsel
    tree
    xremap
    bandwhich
    cpufrequtils
    mutagen
    (pkgs.callPackage ../pkgs/todotxttui.nix { })

    cmake

    # Helix language servers
    nodePackages.bash-language-server
    nodePackages.diagnostic-languageserver
    pyright
    nixd
    verible
    verilator
    clang-tools
    lldb
    nixfmt-rfc-style
    ruff
    pyright
    nodePackages_latest.vscode-json-languageserver
    nodePackages_latest.bash-language-server
    shfmt
    nodePackages_latest.prettier
    cmake-language-server
    marksman
    gnumake
    yaml-language-server
    lua-language-server
    difftastic
    imhex

    glxinfo
    pciutils
    trash-cli
    unar
    zip

    kdePackages.xwaylandvideobridge
    gnome-power-manager
    xorg.xhost
    xorg.xauth
  ];

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

  # Font configuration
  fonts.fontconfig.enable = true;

  # Version that this configuration is compatible with
  home.stateVersion = "25.05";
}
