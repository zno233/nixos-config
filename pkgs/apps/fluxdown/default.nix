{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  nix-update-script,

  # direct ldd dependencies
  gtk3,
  glib,
  fontconfig,
  libgcc,
}:

let
in
stdenv.mkDerivation (finalAttrs: {
  pname = "fluxdown";
  version = "0.4.7";

  src = fetchurl {
    url = "https://github.com/zerx-lab/FluxDown/releases/download/v${finalAttrs.version}/FluxDown-${finalAttrs.version}-linux-x64.deb";
    hash = "sha256-vTJxsG7RWcj6TB/QQL8S2eAD/fnc59npUQwS8EH2l20=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  # autoPatchelfHook patches linked libraries
  buildInputs = [
    gtk3
    glib
    fontconfig
    libgcc
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    dpkg-deb -x "$src" .
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/lib"
    cp -a opt/fluxdown "$out/lib/fluxdown"

    install -Dm644 \
      opt/fluxdown/data/com.fluxdown.app.desktop \
      "$out/share/applications/com.fluxdown.app.desktop"

    substituteInPlace "$out/share/applications/com.fluxdown.app.desktop" \
      --replace-fail "Exec=flux_down %U" "Exec=fluxdown %U"

    if [ -d opt/fluxdown/data/icons ]; then
      cp -r opt/fluxdown/data/icons $out/share/icons
    fi

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/lib/fluxdown/flux_down" "$out/bin/fluxdown" \
      "''${gappsWrapperArgs[@]}" \
      --inherit-argv0
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust-powered multi-protocol download manager with Flutter UI";
    homepage = "https://fluxdown.zerx.dev";
    changelog = "https://github.com/zerx-lab/FluxDown/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "fluxdown";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
