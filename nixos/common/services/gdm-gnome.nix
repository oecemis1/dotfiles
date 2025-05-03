{ pkgs, lib, ... }:

let
in
{
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Customize GNOME installation
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = [pkgs.gnome-tour];

  # GNOME keyring configuration
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
  services.dbus.packages = [ pkgs.gnome-keyring ];
  security.pam.services.gdm-autologin.enableGnomeKeyring = true;

  # Additional GNOME related packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-terminal
    nautilus
    yaru-theme
    gnome-keyring
    libsecret
    gnomeExtensions.dash-to-dock
    dconf-editor
  ];
}
