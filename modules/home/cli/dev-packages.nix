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
        # codex
        inputs.nixpkgs-opencode.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex
        inputs.nixpkgs-opencode.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode
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
        (pkgs.callPackage ../../../pkgs/google-patent-cli.nix { })

        cmake
        texliveMedium

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
        texlab
        gnumake
        yaml-language-server
        lua-language-server
        difftastic
        inputs.nixpkgs-pdf-oxide.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pdf-oxide

        trash-cli
        unar
        zip
      ];
    };
}
