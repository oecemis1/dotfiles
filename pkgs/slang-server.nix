{
  lib,
  gcc14Stdenv,
  fetchgit,
  fetchzip,
  cmake,
  ninja,
  python3,
  catch2_3,
  mimalloc,
}:

let
  # slang-server pins fmt to 12.1.0 and disables find_package(fmt) for ABI
  # consistency. Pre-fetch the exact source so CMake's FetchContent picks it up
  # via FETCHCONTENT_SOURCE_DIR_fmt instead of trying to clone over the network.
  fmtSrc = fetchzip {
    url = "https://github.com/fmtlib/fmt/archive/refs/tags/12.1.0.tar.gz";
    hash = "sha256-ZmI1Dv0ZabPlxa02OpERI47jp7zFfjpeWCy1WyuPYZ0=";
  };
in
gcc14Stdenv.mkDerivation rec {
  pname = "slang-server";
  version = "0.2.5";

  src = fetchgit {
    url = "https://github.com/hudson-trading/slang-server";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-otXgWg7+icsE473i11tjtyNO96ff/tCGTE3+hDEvV28=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    catch2_3
    mimalloc
  ];

  cmakeFlags = [
    "-DSLANG_SERVER_INCLUDE_INSTALL=ON"
    "-DSLANG_SERVER_INCLUDE_TESTS=OFF"
    "-DFETCHCONTENT_SOURCE_DIR_FMT=${fmtSrc}"
  ];

  meta = with lib; {
    description = "SystemVerilog language server built on slang";
    homepage = "https://github.com/hudson-trading/slang-server";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "slang-server";
  };
}
