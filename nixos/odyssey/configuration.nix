{
  pkgs,
  ...
}@specialArgsFromFlake:
let
  defaultArgs = rec {
    hostName = "odyssey";
    timeZone = "Europe/Istanbul";
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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

    username = "orhun";
    uid = 1000;
    userExtraGroups = [ ];
    useHomeManager = true;
    homeManagerImports = [
      ../../home/home.nix
    ];
    homeManagerArgs = {};

    extraImports = [];
    extraGroups = [];

    allowUnfree = true;

    useOSProber = false;
    canTouchEfiVariables = true;
  };
  finalArgs = defaultArgs // specialArgsFromFlake;
in
{
  _module.args = builtins.removeAttrs finalArgs [
    # Prevent Recursion
    "pkgs"
    "lib"
    "inputs"
    "system"
  ];
  imports = [
    ../common/locale.nix

    ../common/user-setup.nix
    ../common/settings.nix
    ../common/bootloader-grub-efi.nix

    ../common/services/gdm-gnome.nix

    ./hardware-configuration.nix
  ] ++ finalArgs.extraImports;
  
  networking = {
    hostName = finalArgs.hostName;
    networkmanager.enable = true;
  };
  
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = finalArgs.username;
  
  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  
  # Basic system packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    unrar
    zip
    unzip
    p7zip
    xsel
    git

    neovim
    kitty
    xterm
    tmux
    fzf
    btop
    starship
  ];
  
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerd-fonts.noto)
      (nerd-fonts.jetbrains-mono)
      # (nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" ]; })
      # jetbrains-mono
      (pkgs.stdenv.mkDerivation {
        name = "sf-pro-fonts";
        src = ../../config/fonts/sf-pro;
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
  
  system.stateVersion = "25.05";
}
