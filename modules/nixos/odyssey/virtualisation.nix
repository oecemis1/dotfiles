{ ... }:
{
  flake.modules.nixos.odyssey =
    { lib, pkgs, ... }:
    let
      windowsCpuIsolation = pkgs.writeShellApplication {
        name = "windows11-cpu-isolation";
        runtimeInputs = with pkgs; [
          libxml2
          systemd
        ];
        text = ''
          case "''${1-}/''${2-}/''${3-}" in
            windows11-office/prepare/begin)
              partition="$(xmllint --xpath 'string(/domain/resource/partition)' -)"
              if [[ "$partition" != /windows11 ]]; then
                echo "windows11-office must use the /windows11 resource partition" >&2
                exit 1
              fi

              for cpu in 2 3 4 5; do
                capacity="/sys/devices/system/cpu/cpu$cpu/cpu_capacity"
                if [[ ! -r "$capacity" ]] || [[ "$(< "$capacity")" != 1024 ]]; then
                  echo "CPU $cpu is not a verified P-core; refusing to start Windows" >&2
                  exit 1
                fi
              done

              trap 'systemctl stop windows11.slice' EXIT
              systemctl start windows11.slice

              cgroup=/sys/fs/cgroup/windows11.slice
              if [[ "$(< "$cgroup/cpuset.cpus.partition")" != isolated ]] ||
                 [[ "$(< "$cgroup/cpuset.cpus.effective")" != 2-5 ]]; then
                echo "Could not exclusively reserve P-cores 2-5 for Windows" >&2
                exit 1
              fi

              trap - EXIT
              ;;
            windows11-office/release/end)
              systemctl stop windows11.slice
              ;;
            */prepare/begin)
              partition="$(xmllint --xpath 'string(/domain/resource/partition)' -)"
              if [[ "$partition" == /windows11 ]]; then
                echo "The /windows11 resource partition is reserved for windows11-office" >&2
                exit 1
              fi
              ;;
          esac
        '';
      };
    in
    {
      # environment.systemPackages = with pkgs; [virt-manager virtualbox distrobox];
      programs.virt-manager.enable = true;

      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        hooks.qemu.windows11-cpu-isolation = lib.getExe windowsCpuIsolation;
        # ISSUE: https://discourse.nixos.org/t/virt-manager-cannot-find-virtiofsd/26752/9
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];

        qemu.verbatimConfig = ''
          group = "users"
          remember_owner = 0
        '';
      };

      systemd.slices.windows11 = {
        description = "Exclusive P-cores for the Windows VM";
        sliceConfig = {
          AllowedCPUs = "2-5";
          CPUSetPartition = "isolated";
        };
      };

      environment.systemPackages = with pkgs; [
        virt-viewer
        virtiofsd
        docker-compose
      ];

      virtualisation.docker.enable = true;
    };
}
