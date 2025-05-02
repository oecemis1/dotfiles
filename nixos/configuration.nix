# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, inputs ? {}, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    
    # Import home-manager module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      unstable = pkgs;
    };
    users.orhun = import ../home/home.nix;
  };

  # Bootloader configuration
  boot.loader = {
    grub = {
      enable = lib.mkDefault true;      
      device = "nodev";
      efiSupport = true;
      default = "saved";
      configurationLimit = 30;
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "odyssey"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    # LC_TIME = "tr_TR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = [pkgs.gnome-tour];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
    settings = {
      Policy = {
        AutoEnable = "false";
      };     
    };
  };

  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.orhun = {
    isNormalUser = true;
    description = "orhun";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "orhun";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Core utilities from install.sh
    curl
    wget
    unrar
    zip
    unzip
    p7zip
    xsel
    git

    # Tools from install_nix.sh
    neovim
    kitty
    xterm
    tmux
    fzf
    btop
    starship

    # Additional GNOME packages
    gnome-tweaks
    gnome-console
    nautilus
    yaru-theme
    gnome-keyring
    libsecret
    gnomeExtensions.dash-to-dock
    dconf-editor
  ];

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
  services.dbus.packages = [ pkgs.gnome-keyring ];
  security.pam.services.gdm-autologin.enableGnomeKeyring = true;

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" ]; })
      jetbrains-mono
      (pkgs.stdenv.mkDerivation {
        name = "sf-pro-fonts";
        src = ../config/fonts/sf-pro; # Updated path to use the config directory
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          cp -r ./*.otf $out/share/fonts/opentype/
        '';
      })
    ];
    enableDefaultPackages = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrains Mono" ];
        sansSerif = [ "SF Pro Display" ];
      };
    };
  };  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?
}
