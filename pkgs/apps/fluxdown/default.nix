{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  nix-update-script,

  # fluxdown-desktop (GPUI client) — direct ELF deps
  libxcb,
  libxkbcommon,

  # fluxdown-agent (GTK3 tray) — direct ELF deps
  gtk3,
  glib,
  cairo,
  gdk-pixbuf,
  libgcc,

  # dlopen'd at runtime (GPUI/wgpu backend probing, status-notifier
  # fallback); runtimeDependencies prepends them to the executable rpath
  wayland,
  libGL,
  vulkan-loader,
  libayatana-appindicator,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fluxdown";
  version = "0.5.3";

  src = fetchurl {
    url = "https://github.com/zerx-lab/FluxDown/releases/download/v${finalAttrs.version}/FluxDown-${finalAttrs.version}-linux-x64.deb";
    hash = "sha256-xY6YvCUSLpvFtyaU4Lxnx3hzRsDTIrLhA8p2YP/Q9tA=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  # Satisfies DT_NEEDED during autoPatchelfHook
  buildInputs = [
    # fluxdown-desktop — GPUI client
    libxcb
    libxkbcommon
    # fluxdown-agent — GTK3 tray
    gtk3
    glib
    cairo
    gdk-pixbuf
    libgcc
  ];

  # Prepended to the rpath of every executable for dlopen'd libraries:
  # no .note.dlopen metadata is shipped, so autoPatchelf cannot resolve
  # these on its own.
  runtimeDependencies = [
    wayland
    libGL
    vulkan-loader
    libayatana-appindicator
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
      usr/share/applications/com.fluxdown.app.desktop \
      "$out/share/applications/com.fluxdown.app.desktop"

    cp -r usr/share/icons "$out/share/icons"

    runHook postInstall
  '';

  postFixup = ''
    # The desktop entry runs `fluxdown-desktop`; `fluxdown` is the upstream
    # flux_down entry script, which routes --silentStart to fluxdown-agent
    # and execs its sibling binaries (they inherit the wrapper env).
    makeWrapper "$out/lib/fluxdown/flux_down" "$out/bin/fluxdown" \
      "''${gappsWrapperArgs[@]}"
    makeWrapper "$out/lib/fluxdown/fluxdown-desktop" "$out/bin/fluxdown-desktop" \
      "''${gappsWrapperArgs[@]}"
    makeWrapper "$out/lib/fluxdown/fluxdown-agent" "$out/bin/fluxdown-agent" \
      "''${gappsWrapperArgs[@]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust-powered multi-protocol download manager with a GPUI interface";
    homepage = "https://fluxdown.zerx.dev";
    changelog = "https://github.com/zerx-lab/FluxDown/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "fluxdown";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
