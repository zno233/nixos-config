{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

let
  version = "0-unstable-2026-10-10";
in
stdenvNoCC.mkDerivation {
  pname = "fcitx5-theme-collect";
  inherit version;

  src = fetchFromGitHub {
    owner = "zno233";
    repo = "fcitx5-theme-collect";
    rev = "aae53f7";
    hash = "sha256-fZzmKiCCvJboc/55xUVHvZSVR7Z4/5puK3RraE32ZiQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fcitx5/themes
    for dir in */; do
      [ -d "$dir" ] && cp -r "$dir"*/ $out/share/fcitx5/themes/
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Collection of fcitx5 themes";
    homepage = "https://github.com/zno233/fcitx5-theme-collect";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
