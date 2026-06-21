{
  lib,
  stdenv,
  kitty,
  gnome-terminal,
  makeWrapper
}:

stdenv.mkDerivation {
  name = "gnome-terminal-wrapper";

  buildInputs = [ makeWrapper ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${kitty}/bin/kitty $out/bin/gnome-terminal \
      --add-flags "--title=Terminal"
  '';

  meta = with lib; {
    description = "Make gnome-terminal package launch kitty";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
