{ lib
, stdenvNoCC
, fetchzip
}:

stdenvNoCC.mkDerivation {
  pname = "clawdbot-app";
  version = "2026.1.23";

  src = fetchzip {
    url = "https://github.com/clawdbot/clawdbot/releases/download/v2026.1.23/Clawdbot-2026.1.23.zip";
    hash = "sha256-HGN8yfDHkoP30YBk11U7kugE6RVkDs9oGwyUdLztToQ=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = "${../scripts/clawdbot-app-install.sh}";

  meta = with lib; {
    description = "Clawdbot macOS app bundle";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
