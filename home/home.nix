{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  username = "orhun";
in {
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
    ./modules/shell.nix
    ./modules/gnome.nix
    ./modules/env.nix
  ];
  
  home.packages = with pkgs; [
    # Browser
    google-chrome
    
    # Development tools
    tmux
    helix
    neovim
    direnv
    
    # Terminal tools
    kitty
    btop
    yazi
    ueberzugpp
    wl-clipboard
    wl-clip-persist
    xdragon
    ripgrep

    cmake

    glxinfo
    pciutils
    
    # Helix language servers
    nodePackages.bash-language-server
    nodePackages.diagnostic-languageserver
    pyright
    nixd
    verible
    verilator
    clang-tools
    lldb
  ];
  
  # Font configuration
  fonts.fontconfig.enable = true; 

  # Version that this configuration is compatible with
  home.stateVersion = "25.05";
}
