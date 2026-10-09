{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doona";
  version = "0.1.0-beta.19";

  src = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v${finalAttrs.version}/doona-${finalAttrs.version}.tar.gz";
    # SHA256SUMS of the release
    hash = "sha256-VQDC9jC7bK2qfC21dY+f/KPKhvtH5j5PFFtr9GEXOgQ=";
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/share/doona"
    shopt -s dotglob
    cp -a ./* "$out/share/doona/"

    runHook postInstall
  '';

  meta = {
    description = "Web UI for the daeuniverse engines honk/dae native API";
    homepage = "https://github.com/Zakkaus/doona";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
