{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  nix-update-script,

  # direct ldd dependencies
  libxkbcommon,
  libxcb,
  libgcc,

  # loaded at runtime by gpui
  wayland,
  vulkan-loader,
}:

let
  archMap = {
    x86_64-linux = "amd64";
    aarch64-linux = "arm64";
  };
  debianArch = archMap.${stdenv.hostPlatform.system};

in
stdenv.mkDerivation (finalAttrs: {
  pname = "zorite";
  version = "0.11.0";

  src = fetchurl {
    url = "https://github.com/packetThrower/zorite/releases/download/v${finalAttrs.version}/zorite_${finalAttrs.version}_${debianArch}.deb";
    hash = "sha256-EvKgwzYGj2ogkpjzIDmEnOp9lR5NtFjV1sNTF5bskEQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # autoPatchelfHook patches linked libraries
  buildInputs = [
    libxkbcommon
    libxcb
    libgcc
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    dpkg-deb -x "$src" .
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/zorite "$out/bin/zorite"

    wrapProgram "$out/bin/zorite" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          vulkan-loader
        ]
      }

    install -Dm644 usr/share/applications/zorite.desktop \
      "$out/share/applications/zorite.desktop"

    substituteInPlace "$out/share/applications/zorite.desktop" \
      --replace-fail 'Exec=zorite' "Exec=$out/bin/zorite"

    if [ -d usr/share/icons ]; then
      cp -r usr/share/icons $out/share/icons
    fi

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local-first, Markdown daily-journal desktop app with wiki-links, whiteboards, and PDF annotation";
    homepage = "https://github.com/packetThrower/zorite";
    changelog = "https://github.com/packetThrower/zorite/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ packetThrower ];
    mainProgram = "zorite";
    platforms = builtins.attrNames archMap;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
