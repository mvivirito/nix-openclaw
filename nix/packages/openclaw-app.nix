{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "openclaw-app";
  version = "2026.2.22";

  src = fetchzip {
    url = "https://github.com/openclaw/openclaw/releases/download/v2026.2.22/OpenClaw-2026.2.22.zip";
    hash = "sha256-r8w8zsm7eTV2IgoTs59hl8iJtmtU8RKU8G54GMhrIMc=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = "${../scripts/openclaw-app-install.sh}";

  meta = with lib; {
    description = "OpenClaw macOS app bundle";
    homepage = "https://github.com/openclaw/openclaw";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
