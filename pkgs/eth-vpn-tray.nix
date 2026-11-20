{
  lib,
  stdenvNoCC,
  python3,
  gobject-introspection,
  wrapGAppsHook3,
  gtk3,
  libayatana-appindicator,
  networkmanager,
  networkmanager-openconnect,
  adwaita-icon-theme,
}:
stdenvNoCC.mkDerivation {
  pname = "eth-vpn-tray";
  version = "1.0";

  dontUnpack = true;
  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    libayatana-appindicator
    networkmanager
    networkmanager-openconnect
    adwaita-icon-theme
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ${./eth-vpn-tray.py} $out/bin/eth-vpn-tray
    substituteInPlace $out/bin/eth-vpn-tray \
      --replace-fail '@PYTHON@' '${python3.withPackages (ps: [ ps.pygobject3 ])}/bin/python3' \
      --replace-fail '@AUTH_DIALOG@' '${networkmanager-openconnect}/libexec/nm-openconnect-auth-dialog' \
      --replace-fail '@NMCLI@' '${networkmanager}/bin/nmcli'
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test -x ${networkmanager-openconnect}/libexec/nm-openconnect-auth-dialog
    $out/bin/eth-vpn-tray --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Manually launched ETH student VPN tray controls";
    mainProgram = "eth-vpn-tray";
    platforms = lib.platforms.linux;
  };
}
