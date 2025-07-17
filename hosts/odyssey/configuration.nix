{
  pkgs,
  config,
  lib,
  ...
}@specialArgsFromFlake:
let
  defaultArgs = {
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
    homeManagerArgs = { };

    maxJobs = 16;
    maxSubstitutionJobs = 256;
    nixCores = 16;

    extraSubstituters = [ ];
    extraTrustedPublicKeys = [ ];

    extraImports = [ ];
    extraGroups = [ ];

    allowUnfree = true;

    useOSProber = true;
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
    ../common/services/warp.nix

    ./hardware-configuration.nix
    ./hardware-gpu.nix
    ./virtualisation.nix
    # ./battery.nix
  ] ++ finalArgs.extraImports;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPatches =
  #   let
  #     version = config.boot.kernelPackages.kernel.version;
  #   in
  #   [
  #     {
  #       name = "g16";
  #       patch = builtins.fetchurl {
  #         url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-${lib.versions.majorMinor version}/asus-patch-series.patch";
  #         sha256 = "sha256:0sybd6l38fh68pmq35fwzqpm9sjxnainz36syybni0mbnj4zkbrb";
  #       };
  #       extraStructuredConfig = with lib.kernel; {
  #         ASUS_ARMOURY = module;
  #       };
  #       extraMeta = {
  #         branch = lib.versions.majorMinor version;
  #       };
  #     }
  #   ];

  boot.kernelParams = [
    "i915.enable_dpcd_backlight=1"
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];

  services.supergfxd.enable = true;
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  networking = {
    hostName = finalArgs.hostName;
    networkmanager.enable = true;
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = finalArgs.username;

  # Workaround for GNOME autologin
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
    enable = true;
    powerOnBoot = true;
    settings = {
      Policy = {
        AutoEnable = "false";
      };
    };
  };

  services.blueman.enable = true;

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
      corefonts
      # (nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" ]; })
      # jetbrains-mono
      (pkgs.stdenv.mkDerivation {
        name = "sf-pro-fonts";
        src = ../../.config/fonts/sf-pro;
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

  nixpkgs.overlays = [
    (import ../overlays)
  ];

  system.stateVersion = "25.05";
}
