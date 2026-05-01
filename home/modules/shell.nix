{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./aliases.nix
    ./env.nix
  ];
  # Bash configuration
  programs.bash = {
    enable = true;

    historyFile = "$HOME/.local/state/bash/history";
    historyFileSize = -1;
    historySize = -1;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    enableCompletion = true;
    bashrcExtra = ''
      PROMPT_COMMAND="history -a; history -n"
    ''; # Environment variables and functions
    initExtra = ''
      export EDITOR=hx

      yazi_cd() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
          yazi --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd" || return
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

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      mode = "enabled";
    };
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityFile = "~/.ssh/id_orhun";
      addKeysToAgent = "yes";
    };
    extraConfig = ''
      Include ~/.ssh/config.local
    '';
  };

  # Ensure Yazi configuration directory exists
  # home.activation = {
  #   ensureYaziDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     mkdir -p $HOME/.config/yazi
  #   '';
  # };
}
