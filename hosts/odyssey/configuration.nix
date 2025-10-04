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

    # ../common/services/gdm-gnome.nix
    ../common/services/sddm-hyprland.nix
    ../common/services/warp.nix

    ./hardware-configuration.nix
    ./hardware-gpu.nix
    ./virtualisation.nix
    # ./wifi.nix
    ./power-management.nix
  ] ++ finalArgs.extraImports;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelPatches = [
    {
      name = "iwlwifi_patch";
      patch = ../../pkgs/iwlwifi-no-disable-all-chans.patch;
    }
  ];

  boot.kernelParams = [
    "intel_pstate"
    # "intel_pstate=no_hwp"
    "resume_offset=13757716"
    "i915.enable_dpcd_backlight=1"
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];

  services.supergfxd.enable = true;
  specialisation = {
    integrated-graphics.configuration = {
      services.supergfxd = {
        enable = true;
        settings = {
          mode = "Integrated";
          vfio_enable = false;
          vfio_save = false;
          always_reboot = false;
          no_logind = false;
          logout_timeout_s = 180;
          hotplug_type = "None";
        };
      };
    };
    # hybrid-graphics.configuration = {
    #   services.supergfxd.settings = {
    #     mode = "Hybrid";
    #   };
    # };
  };

  services.asusd = {
    enable = true;
    enableUserService = true;

    fanCurvesConfig = {
      text = ''
        (
          profiles: (
                quiet: [
                    (
                        fan: CPU,
                        pwm: (0, 0, 99, 157, 173, 182, 190, 215),
                        temp: (30, 50, 53, 60, 67, 77, 86, 100),
                        enabled: true,
                    ),
                    (
                        fan: GPU,
                        pwm: (0, 0, 99, 157, 173, 182, 190, 215),
                        temp: (30, 50, 53, 60, 67, 77, 86, 100),
                        enabled: true,
                    ),
                ],
                balanced: [
                    (
                        fan: CPU,
                        pwm: (13, 26, 51, 77, 115, 153, 191, 217),
                        temp: (30, 40, 50, 60, 70, 80, 90, 100),
                        enabled: true,
                    ),
                    (
                        fan: GPU,
                        pwm: (13, 26, 51, 77, 115, 153, 191, 217),
                        temp: (30, 40, 50, 60, 70, 80, 90, 100),
                        enabled: true,
                    ),
                ],
                performance: [
                    (
                        fan: CPU,
                        pwm: (0, 0, 0, 80, 150, 220, 250, 250),
                        temp: (30, 40, 50, 65, 70, 80, 90, 100),
                        enabled: true,
                    ),
                    (
                        fan: GPU,
                        pwm: (0, 0, 0, 80, 150, 220, 250, 250),
                        temp: (30, 40, 50, 60, 70, 80, 90, 100),
                        enabled: true,
                    ),
                ],
                custom: [],
            ),
        )
      '';
    };
  };

  systemd.services.asusd = {
    restartTriggers = [ config.services.asusd.fanCurvesConfig.text ];
  };
  programs.rog-control-center.enable = true;

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
    linuxPackages.turbostat
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerd-fonts.noto)
      (nerd-fonts.jetbrains-mono)
      (nerd-fonts.monaspace)
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
