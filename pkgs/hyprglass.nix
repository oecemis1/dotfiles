{
  lib,
  hyprlandPlugins,
  fetchFromGitHub,
}:
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "hyprglass";
  version = "0.7.0-liquid-glass";

  src = fetchFromGitHub {
    owner = "hyprnux";
    repo = "hyprglass";
    tag = "v0.7.0";
    hash = "sha256-x/584kY+XXlU/OWKtZAFo89VtowjLXs1DiP9PC0o0Os=";
  };

  # Preserve the original regions patch. The Liquid Glass patch is generated
  # against the exact upstream source with the regions patch applied.
  patches = [
    ./hyprglass-regions.patch
    ./hyprglass-liquid-glass.patch
  ];

  installPhase = ''
    runHook preInstall
    install -Dm644 hyprglass.so $out/lib/libhyprglass.so
    install -Dm644 LICENSE $out/share/licenses/hyprglass/LICENSE
    install -Dm644 THIRD_PARTY_NOTICES.md $out/share/licenses/hyprglass/THIRD_PARTY_NOTICES.md
    runHook postInstall
  '';

  meta = {
    description = "Liquid Glass effect for Hyprland windows and layer surfaces";
    homepage = "https://github.com/hyprnux/hyprglass";
    license = with lib.licenses; [ bsd3 mit ];
    platforms = [ "x86_64-linux" ];
  };
}
