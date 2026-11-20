{
  lib,
  stdenvNoCC,
  python3,
  gobject-introspection,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  glib,
  gtk3,
  adwaita-icon-theme,
}:
let
  python = python3.withPackages (ps: [ ps.pygobject3 ]);
in
stdenvNoCC.mkDerivation {
  pname = "asus-lighting";
  version = "1.0";

  dontUnpack = true;
  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    copyDesktopItems
  ];
  buildInputs = [
    glib
    gtk3
    adwaita-icon-theme
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "asus-lighting";
      desktopName = "ASUS Lighting";
      comment = "Control the keyboard backlight and lid LEDs";
      exec = "asus-lighting";
      icon = "input-keyboard-symbolic";
      terminal = false;
      categories = [ "Settings" ];
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm644 ${./asus_lighting_core.py} $out/lib/asus-lighting/asus_lighting_core.py
    install -Dm755 ${./asus-lighting.py} $out/bin/asus-lighting
    substituteInPlace $out/bin/asus-lighting \
      --replace-fail '@PYTHON@' '${python}/bin/python3' \
      --replace-fail '@CORE_DIR@' "$out/lib/asus-lighting"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export PYTHONDONTWRITEBYTECODE=1
    PYTHONPATH=$out/lib/asus-lighting ${python}/bin/python3 ${./asus-lighting-test.py}
    $out/bin/asus-lighting --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Keyboard backlight and lid LED controls for ASUS ROG laptops";
    mainProgram = "asus-lighting";
    platforms = lib.platforms.linux;
  };
}
