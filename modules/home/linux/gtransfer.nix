{ ... }:
{
  flake.modules.homeManager.linux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hosts = [ "safari-desktop36" ];
      dest = config.xdg.userDirs.download;
      unitName = host: "gtransfer-pull-${host}";
      forEachHost = lib.genAttrs' hosts;
      pull = pkgs.writeShellApplication {
        name = "gtransfer-pull";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.openssh
          pkgs.rsync
        ];
        text = ''
          host="$1"
          dest=${lib.escapeShellArg dest}

          mapfile -d "" -t paths
          sources=()
          for path in "''${paths[@]}"; do
            if [[ $path != /* ]]; then
              echo "gtransfer-pull: refusing relative path '$path'"
              exit 1
            fi
            sources+=("$host:$path")
          done
          if [[ ''${#sources[@]} -eq 0 ]]; then
            exit 0
          fi

          echo "Pulling into $HOSTNAME:$dest/"
          mkdir -p "$dest"
          exec rsync -avP -e "ssh -o BatchMode=yes" -- "''${sources[@]}" "$dest/"
        '';
      };
    in
    {
      programs.ssh.settings = forEachHost (
        host:
        lib.nameValuePair "Match originalhost ${host} sessiontype shell" {
          RemoteForward = "/run/user/%i/gtransfer-pull.sock /run/user/%i/gtransfer-pull/${host}.sock";
        }
      );

      systemd.user.sockets = forEachHost (
        host:
        lib.nameValuePair (unitName host) {
          Unit.Description = "gtransfer pull requests from ${host}";
          Socket = {
            ListenStream = "%t/gtransfer-pull/${host}.sock";
            SocketMode = "0600";
            Accept = true;
          };
          Install.WantedBy = [ "sockets.target" ];
        }
      );

      systemd.user.services = forEachHost (
        host:
        lib.nameValuePair "${unitName host}@" {
          Unit.Description = "Pull files from ${host} into ${dest}";
          Service = {
            ExecStart = "${lib.getExe pull} ${host}";
            StandardInput = "socket";
          };
        }
      );
    };
}
