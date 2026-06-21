# Alternative GNOME desktop — UNWIRED (own namespace, not used by any host).
{ ... }:
{
  flake.modules.nixos.gnomeDesktop =
    { pkgs, ... }:
    {
      # Enable the X11 windowing system
      services.xserver.enable = true;

      # Enable the GNOME Desktop Environment
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Customize GNOME installation
      services.gnome.core-apps.enable = false;
      environment.gnome.excludePackages = [ pkgs.gnome-tour ];
      programs.gnome-disks.enable = true;

      # GNOME keyring configuration
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.gdm.enableGnomeKeyring = true;
      environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
      services.dbus.packages = [ pkgs.gnome-keyring ];
      security.rtkit.enable = true;

      # Additional GNOME related packages
      environment.systemPackages = with pkgs; [
        gnome-tweaks
        gnome-terminal
        gnome-calculator
        nautilus
        yaru-theme
        libsecret
        dconf-editor
        baobab
      ];
    };
}
