#!/usr/bin/env bash

nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.vim
nix-env -iA nixpkgs.helix
nix-env -iA nixpkgs.yazi

nix-env -iA nixpkgs.fzf
if ! grep -q "eval \"\$(fzf --bash)\"" "$HOME/.bashrc"; then
    echo 'eval "$(fzf --bash)"' >> "$HOME/.bashrc"
fi

nix-env -iA nixpkgs.direnv
if ! grep -q "eval \"\$(direnv hook bash)\"" "$HOME/.bashrc"; then
    echo 'eval "$(direnv hook bash)"' >> "$HOME/.bashrc"
fi 

nix-env -iA nixpkgs.btop

# helix language servers
nix-env -iA nixpkgs.nodePackages_latest.bash-language-server
nix-env -iA nixpkgs.nodePackages.diagnostic-languageserver
nix-env -iA nixpkgs.pyright
nix-env -iA nixpkgs.nixd
nix-env -iA nixpkgs.verible
nix-env -iA nixpkgs.verilator
nix-env -iA nixpkgs.clang-tools
nix-env -iA nixpkgs.lldb
