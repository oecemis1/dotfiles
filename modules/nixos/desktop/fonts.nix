{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
          (nerd-fonts.noto)
          (nerd-fonts.jetbrains-mono)
          (nerd-fonts.monaspace)
          corefonts
          (pkgs.stdenv.mkDerivation {
            name = "sf-pro-fonts";
            src = ../../../.config/fonts/sf-pro;
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
    };
}
