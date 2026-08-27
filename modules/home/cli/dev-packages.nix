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
        opencode
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
        vscode-langservers-extracted # json/css/html servers for helix and nvim
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
