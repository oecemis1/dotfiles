{ ... }:
{
  flake.modules.homeManager.cli =
    { ... }:
    {
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

      programs.starship = {
        enable = true;
        enableBashIntegration = true;
      };

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

      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        # settings uses upstream OpenSSH directive names verbatim
        settings."*" = {
          IdentityFile = "~/.ssh/id_orhun";
          AddKeysToAgent = "yes";
        };
        extraConfig = ''
          Include ~/.ssh/config.local
        '';
      };
    };
}
