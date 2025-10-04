{
  pkgs,
  inputs,
  dotfilesDir ? throw "Set this to your dotfiles dir",
  ...
}:
{
  xdg =
    let
      mutable_configs = [
      ];

      immutable_configs = [
        "btop"
        "fonts"
        "gdb"
        "helix"
        "kitty"
        "tmux"
        "yazi"
        "qalculate"
        "mimeapps.list"
        "GNOME-xdg-terminals.list"
        "xdg-terminals.list"
        "tofi"
      ];

      immutable_data = [
        # "applications"
      ];

      mutable_data = [
      ];

      mutable_state = [
        # "bash"
        "gdb"
      ];

      makeMutable = path: file: {
        target = file;
        source = pkgs.runCommand "${file}-dotfiles" { } ''
          ln -s "${dotfilesDir}/${path}/${file}" $out
        '';
        recursive = true;
      };

      makeImmutable = path: file: {
        target = file;
        source = "${inputs.self}/${path}/${file}";
        recursive = true;
      };

      # Generate the attribute sets for each type of file
      mutableConfigFiles = builtins.listToAttrs (
        map (file: {
          name = file;
          value = makeMutable ".config" file;
        }) mutable_configs
      );

      immutableConfigFiles = builtins.listToAttrs (
        map (file: {
          name = file;
          value = makeImmutable ".config" file;
        }) immutable_configs
      );

      mutableDataFiles = builtins.listToAttrs (
        map (file: {
          name = file;
          value = makeMutable ".local/share" file;
        }) mutable_data
      );

      mutableStateFiles = builtins.listToAttrs (
        map (file: {
          name = file;
          value = makeMutable ".local/state" file;
        }) mutable_state
      );

      immutableDataFiles = builtins.listToAttrs (
        map (file: {
          name = file;
          value = makeImmutable ".local/share" file;
        }) immutable_data
      );
    in
    {
      # Combine all file configurations
      configFile = mutableConfigFiles // immutableConfigFiles;
      dataFile = mutableDataFiles // immutableDataFiles;
      stateFile = mutableStateFiles;

      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config = {
          common = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
            "org.freedesktop.impl.portal.GlobalShortcuts" = [ "hyprland" ];
            # "org.freedesktop.impl.portal.FileChooser" = [
            #   "termfilechooser"
            # ]; # not working
          };
          hyprland = {
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-termfilechooser
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
    };

  home.file = {
    ".local/bin" = {
      source = "${inputs.self}/.local/bin";
      recursive = true;
      executable = true;
    };
    ".local/docker-scripts" = {
      source = "${inputs.self}/.local/docker-scripts";
      recursive = true;
      executable = true;
    };
    ".config/wallpapers" = {
      source = "${inputs.self}/assets";
      recursive = true;
      executable = false;
    };
  };
}
