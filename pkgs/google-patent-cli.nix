{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
}:

rustPlatform.buildRustPackage {
  pname = "google-patent-cli";
  version = "0.2.3-unstable-2026-04-19";

  src = fetchFromGitHub {
    owner = "sonesuke";
    repo = "google-patent-cli";
    rev = "803e0e82aa6ae13d9c2a8015e9ff2b3e3b02092e";
    hash = "sha256-+11PadEl3KuUWDoj6Qlgkv6pk2eSLkvqL+2cVJnKijg=";
  };

  cargoHash = "sha256-GKdiU0hlcqXvBI1796vbFw81xpPAIB9yI43lE9nV1i4=";

  nativeBuildInputs = [ perl ];

  doCheck = false;

  meta = {
    description = "Google Patents search and fetch CLI with an MCP server";
    homepage = "https://github.com/sonesuke/google-patent-cli";
    license = lib.licenses.mit;
    mainProgram = "google-patent-cli";
    platforms = lib.platforms.unix;
  };
}
