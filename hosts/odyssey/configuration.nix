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
    userExtraGroups = [ "wireshark" ];
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
    extraGroups = [ "wireshark" ];

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
  ]
  ++ finalArgs.extraImports;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  systemd.services.pre-hibernate-disable-input-wake = {
    description = "Unbind pin controller before hibernate to prevent wake";
    before = [ "systemd-hibernate.service" ];
    wantedBy = [ "systemd-hibernate.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo INTC105E:00 > /sys/bus/platform/drivers/meteorlake-pinctrl/unbind'";
    };
  };

  systemd.services.post-hibernate-restore-input = {
    description = "Rebind pin controller after hibernate";
    after = [ "systemd-hibernate.service" ];
    wantedBy = [ "systemd-hibernate.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo INTC105E:00 > /sys/bus/platform/drivers/meteorlake-pinctrl/bind && ${pkgs.kmod}/bin/rmmod i2c_hid_acpi && ${pkgs.kmod}/bin/modprobe i2c_hid_acpi'";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_testing;

  boot.kernelParams = [
    "intel_pstate"
    "intel_idle.max_cstate=99"
    "processor.max_cstate=99"
    "ahci.mobile_lpm_policy=3"
    "pcie_aspm=force"
    "pcie_aspm.policy=powersupersave"
    # "intel_pstate=no_hwp"
    "resume_offset=13757716"
    "i915.enable_dpcd_backlight=1"
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];

  services.fstrim.enable = true;

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
    # enableUserService = true;
    fanCurvesConfig.source = ./fan_curves.ron;
    asusdConfig.source = ./asusd.ron;
  };

  systemd.services.asusd = {
    restartTriggers = [ config.services.asusd.fanCurvesConfig.source ];
  };
  programs.rog-control-center.enable = true;

  systemd.user.services.tmux = {
    serviceConfig = {
      TimeoutStopSec = "5s";
    };
  };

  networking = {
    hostName = finalArgs.hostName;
    networkmanager.enable = true;
  };
  services.mullvad-vpn.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
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
      (pkgs.stdenv.mkDerivation {
        name = "sf-mono-fonts";
        src = ../../.config/fonts/sf-mono;
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
