# Vendored from nixpkgs after its removal there (the package was dropped
# with gtk-engine-murrine, which only the GTK2 variant needed). GTK2 and
# the other unused desktop payloads (cinnamon, gnome-shell, metacity,
# unity, xfwm4, kde) are retired here: only GTK3/4 + cursors install.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

let
  themeName = "Dracula";
in
stdenvNoCC.mkDerivation {
  pname = "dracula-theme";
  version = "4.0.0-unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "dracula";
    repo = "gtk";
    rev = "1188c8eabdfc33c42738862b91caf7fab884c767";
    hash = "sha256-Z3dMgkk5SvpCWjxdm8hd5FBeEvq0uCJuj3zC5boQEdk=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/${themeName}
    cp -a {assets,gtk-3.0,gtk-3.20,gtk-4.0,index.theme} $out/share/themes/${themeName}

    mkdir -p $out/share/icons/Dracula-cursors
    mv kde/cursors/Dracula-cursors/index.theme $out/share/icons/Dracula-cursors/cursor.theme
    mv kde/cursors/Dracula-cursors/cursors $out/share/icons/Dracula-cursors/cursors

    runHook postInstall
  '';

  meta = {
    description = "Dracula variant of the Ant theme";
    homepage = "https://github.com/dracula/gtk";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
  };
}
