{ self, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    let
      # live checkout — gdb state must stay writable
      dotfilesDir = "/home/orhun/Documents/dotfiles";
      immutable = name: {
        source = "${self}/.config/${name}";
        recursive = true;
      };
      mutableState = file: {
        source = pkgs.runCommand "${file}-dotfiles" { } ''
          ln -s "${dotfilesDir}/.local/state/${file}" $out
        '';
        recursive = true;
      };
    in
    {
      xdg.configFile = {
        btop = immutable "btop";
        gdb = immutable "gdb";
        helix = immutable "helix";
        kitty = immutable "kitty";
        nvim = immutable "nvim";
        opencode = immutable "opencode";
        tmux = immutable "tmux";
        yazi = immutable "yazi";
      };

      xdg.stateFile = {
        gdb = mutableState "gdb";
      };
    };
}
