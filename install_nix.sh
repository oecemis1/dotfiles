#!/usr/bin/env bash

nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.vim
nix-env -iA nixpkgs.helix
if ! grep -q "EDITOR=hx" "$HOME/.bashrc"; then
    echo 'export EDITOR=hx' >> "$HOME/.bashrc"
    echo 'export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"' >> "$HOME/.bashrc"
fi

nix-env -iA nixpkgs.yazi
if ! grep -q "alias yazi=\"\$HOME/.local/bin/yazi_cd\"" "$HOME/.bashrc"; then
    echo 'alias yazi="$HOME/.local/bin/yazi_cd"' >> "$HOME/.bashrc"
    echo 'alias ya=yazi' >> "$HOME/.bashrc"
fi
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi
if [ ! -f "$HOME/.local/bin/yazi_cd" ]; then
    cp yazi_cd "$HOME/.local/bin"
    sudo chmod +x "$HOME/.local/bin/yazi_cd"
fi

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
