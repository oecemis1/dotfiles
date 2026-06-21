{ ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;

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
      ];
    };
}
