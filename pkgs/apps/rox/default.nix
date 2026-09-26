{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  nix-update-script,

  # direct ldd dependencies
  alsa-lib,
  libxcb,
  libxkbcommon,
  libgcc,

  # loaded at runtime by gpui/glutin/blade (see header)
  vulkan-loader,
  wayland,
  libglvnd,
  libx11,
  libxrender
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rox";
  version = "1.28.6";

  src = fetchurl {
    url = "https://github.com/zealsprince/rox/releases/download/v${finalAttrs.version}/rox_${finalAttrs.version}_amd64.deb";
    hash = "sha256-hJXvqlLUrtN2qhjmPb/TlswklYOOFYNk1V2PcGpfnJ0=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # autoPatchelfHook patches linked libraries
  buildInputs = [
    stdenv.cc.cc.lib
    libgcc
    alsa-lib
    libxcb
    libxkbcommon
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    dpkg-deb -x "$src" .
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/rox "$out/bin/rox"
    install -Dm755 usr/bin/rox-mcp "$out/bin/rox-mcp"

    install -Dm644 usr/share/applications/rox.desktop "$out/share/applications/rox.desktop"
    install -Dm644 usr/share/icons/hicolor/scalable/apps/rox.svg \
      "$out/share/icons/hicolor/scalable/apps/rox.svg"
    install -Dm644 usr/share/pixmaps/rox.png "$out/share/pixmaps/rox.png"
    install -Dm644 usr/share/metainfo/rox.metainfo.xml "$out/share/metainfo/rox.metainfo.xml"
    install -Dm644 usr/share/doc/rox/copyright "$out/share/doc/rox/copyright"

    # both `Exec=rox %F` and the Enqueue action's `Exec=rox --enqueue %F`
    substituteInPlace "$out/share/applications/rox.desktop" \
      --replace-fail 'Exec=rox' "Exec=$out/bin/rox"

    # dlopened libs are absent from rpath (nothing links them), so the fixup
    # phase cannot discover them either — hand them to the loader directly.
    wrapProgram "$out/bin/rox" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath (
          [
            vulkan-loader
            wayland
            libglvnd
            libxkbcommon
            libx11
            libxrender
          ]
        )
      }

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A desktop music player for large, carefully tagged local libraries";
    homepage = "https://github.com/zealsprince/rox";
    changelog = "https://github.com/zealsprince/rox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "rox";
    # only amd64 is published as a deb
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
