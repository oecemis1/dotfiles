{ ... }:
{
  flake.modules.nixos.desktop =
    { lib, pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "sddm-astronaut-theme";

        wayland.enable = true;

        extraPackages = with pkgs; [
          kdePackages.qtwayland
          kdePackages.qtmultimedia
          kdePackages.qtsvg
          kdePackages.qtvirtualkeyboard
        ];
        settings = {
          General = {
            DefaultSession = "hyprland.desktop";
          };
          Wayland = {
            CompositorCommand = "${lib.getExe pkgs.weston} --backend=drm-backend.so --shell=kiosk-shell.so";
          };
        };
      };

      services = {
        dbus.enable = true;
        xserver.enable = true;
        xserver.excludePackages = [ pkgs.xterm ];
        gnome.gnome-keyring.enable = true;
        openssh.enable = true;
        dbus.packages = [ pkgs.gnome-keyring ];
        udisks2.enable = true;
      };
      programs.gnome-disks.enable = true;

      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };

      security = {
        pam = {
          services.hyprlock = { };
          loginLimits = [
            {
              domain = "*";
              type = "hard";
              item = "nofile";
              value = "1048576";
            }
          ];
        };

        rtkit.enable = lib.mkDefault true;
      };

      environment.systemPackages = with pkgs; [
        gnome-terminal
        nautilus
        yaru-theme
        libsecret
        baobab
        (pkgs.callPackage ../../../pkgs/sddm-astronaut.nix {
          themeConfig = {
            General = {
              Background = "${../../../assets/wallpaper.jpg}";
            };
          };
          # theme = "pixel_sakura";
        })
      ];
    };
}
