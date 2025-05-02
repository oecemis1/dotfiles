{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs to know which is the home directory and username
  home.username = "orhun";
  home.homeDirectory = "/home/orhun";
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  
  # Import modules
  imports = [
    ./xdg.nix
    ./modules/shell.nix
    ./modules/gnome.nix
  ];
  
  home.packages = with pkgs; [
    # Browser
    google-chrome
    
    # Development tools
    helix
    neovim
    direnv
    
    # Terminal tools
    tmux
    kitty
    btop
    yazi
    ueberzugpp
    
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
