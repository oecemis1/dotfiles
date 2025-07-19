{
  pkgs,
  lib,
  kernel,
  kernelModuleMakeFlags,
  bc,
  ...
}:
let
  version = "1.19.10";
  pname = "RTL8851BU";
  src = pkgs.fetchFromGitHub {
    owner = "fofajardo";
    repo = "rtl8851bu";
    rev = "c0c1e8400a52f904158f209e53da5d8fcc34934a";
    hash = "sha256-hxpvcrTb59OuIqJa1bbxDvQRuhPGVJAjwygHFlI3Xls=";
  };
  # runtime and librarys are unused in the derivation, so they can be removed
in
pkgs.stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    bc
    pkgs.nukeReferences
  ] ++ kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags;

  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace-fail '$(KSRC)' '${kernel.dev}/lib/modules/${kernel.modDirVersion}/build' \
      --replace-fail '/sbin/depmod' '#' \
      --replace-fail '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/" \
      --replace-fail '/lib/firmware' "$out/lib/firmware"
  '';

  preInstall = ''
    # Create directories for both the kernel module and the firmware
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/" "$out/lib/firmware"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Driver for RTL8851BU";
    homepage = "https://github.com/fofajardo/rtl8851bu.git";
    license = licenses.gpl2;
    sourceProvenance = [
      sourceTypes.fromSource
    ];
    platforms = platforms.linux;
  };
}
