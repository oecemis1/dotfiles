{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Development tools
        tmux
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        helix
        # (pkgs.callPackage ../../../pkgs/helix.nix { })
        neovim
        direnv
        libqalculate

        # Terminal tools
        kitty
        btop
        yazi
        ouch
        ffmpegthumbnailer
        bat
        ripgrep
        yek
        tree
        bandwhich
        (pkgs.callPackage ../../../pkgs/todotxttui.nix { })
        (pkgs.callPackage ../../../pkgs/slang-server.nix { })

        cmake

        # Helix language servers / formatters
        bash-language-server
        diagnostic-languageserver
        pyright
        nixd
        verible
        verilator
        clang-tools
        lldb
        nixfmt
        ruff
        vscode-json-languageserver
        shfmt
        prettier
        cmake-language-server
        marksman
        gnumake
        yaml-language-server
        lua-language-server
        difftastic

        trash-cli
        unar
        zip
      ];
    };
}
