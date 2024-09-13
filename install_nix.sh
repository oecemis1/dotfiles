#!/usr/bin/env bash

nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.helix
nix-env -iA nixpkgs.yazi
nix-env -iA nixpkgs.fzf
nix-env -iA nixpkgs.btop

if ! grep -q "eval \"\$(fzf --bash)\"" "$HOME/.bashrc"; then
    echo 'eval "$(fzf --bash)"' >> "$HOME/.bashrc"
fi
