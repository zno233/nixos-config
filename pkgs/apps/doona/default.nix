{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doona";
  version = "0.1.0-beta.5";

  src = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v${finalAttrs.version}/doona-${finalAttrs.version}.tar.gz";
    hash = "sha256-heCWY+sGAqrPKWxiTneU5srJjPU1mHYTl8cnQEVgBzE=";
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
