
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./aliases.nix
    ./env.nix
  ];
  # Bash configuration
  programs.bash = {
    enable = true;
    
    # Environment variables and functions
    initExtra = ''
      export EDITOR=hx
      
      # Define yazi_cd exactly as provided
      yazi_cd() {
          tmp="$(mktemp -t "yazi-cwd.XXXXX")"
          yazi --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }
    '';
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  
  # FZF integration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  
  # Direnv integration
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  
  # Ensure Yazi configuration directory exists
  # home.activation = {
  #   ensureYaziDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     mkdir -p $HOME/.config/yazi
  #   '';
  # };
}
