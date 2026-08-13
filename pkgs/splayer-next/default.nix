{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  avahi,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gnutls,
  gtk3,
  krb5,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpng,
  libselinux,
  libxkbcommon,
  nspr,
  nss,
  pango,
  pcre2,
  libffi,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  systemdLibs,
  util-linux,
  vulkan-loader,
  zlib,
}:
let
  pname = "splayer-next";
  version = "1.0.0";
  # 直接来自官方 v1.0.0 release 的 Linux .deb 资产
  # https://github.com/SPlayer-Dev/SPlayer-Next/releases/tag/v1.0.0
  sources = {
    x86_64-linux = {
      url = "https://github.com/SPlayer-Dev/SPlayer-Next/releases/download/v${version}/splayer-next-${version}-amd64.deb";
      hash = "sha256-9pTlKtqRA3ImhkznbUh5Rsh5lJzF0CGuJYWX8mbFTmo=";
    };
    aarch64-linux = {
      url = "https://github.com/SPlayer-Dev/SPlayer-Next/releases/download/v${version}/splayer-next-${version}-arm64.deb";
      hash = "sha256-Phy2Jrxo4dzTMxDekYgmUj9vY3fv8XR9YxH/WdrFU+I=";
    };
  };
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl sources.${stdenv.hostPlatform.system};
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    copyDesktopItems
  ];
  # SPlayer-Next 自带完整的 Electron/Chromium 运行时（libffmpeg.so 等已随包提供），
  # 但有两处 NixOS 特有的坑会导致 GPU 进程完全退化到软件渲染：
  # 1. Chromium 的 ANGLE 要按 soname dlopen 原生 EGL（libEGL.so.1，即 libglvnd），
  #    但 .deb 自带的 ANGLE 不依赖 libglvnd，autoPatchelfHook 不会把它加进 RUNPATH，
  #    故 wrapper 里显式 prefix LD_LIBRARY_PATH（libglvnd 会分发到 /run/opengl-driver 的 mesa）。
  # 2. .deb 自带的 libvulkan.so.1 只搜索 /usr/share/vulkan/icd.d 等标准路径，
  #    在 NixOS 上找不到任何 Vulkan 驱动（ICD 位于 /run/opengl-driver），
  #    故用 nixpkgs 的 vulkan-loader（已补丁支持 NixOS 驱动路径）替换，以启用硬件加速。
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    avahi
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gnutls
    gtk3
    krb5
    libdrm
    libgbm
    libglvnd
    libnotify
    libpng
    libselinux
    libxkbcommon
    nspr
    nss
    pango
    pcre2
    libffi
    systemdLibs
    util-linux
    vulkan-loader
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    zlib
  ];
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt $out/bin $out/share/icons/hicolor/512x512/apps
    cp -r opt/SPlayer-Next $out/opt/splayer-next
    chmod +x $out/opt/splayer-next/SPlayer-Next
    # 替换 .deb 自带的 Vulkan loader（详见 buildInputs 注释）
    ln -sf ${vulkan-loader}/lib/libvulkan.so.1 $out/opt/splayer-next/libvulkan.so.1
    install -Dm444 usr/share/icons/hicolor/512x512/apps/SPlayer-Next.png \
      $out/share/icons/hicolor/512x512/apps/splayer-next.png
    makeWrapper $out/opt/splayer-next/SPlayer-Next $out/bin/splayer-next \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${libglvnd}/lib \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
    runHook postInstall
  '';
  desktopItems = [
    (makeDesktopItem {
      name = "splayer-next";
      desktopName = "SPlayer-Next";
      genericName = "Music Player";
      comment = "Cross-platform desktop music player with rich lyric support and wide audio format compatibility";
      exec = "splayer-next %U";
      icon = "splayer-next";
      terminal = false;
      type = "Application";
      startupWMClass = "top.imsyy.splayer_next";
      categories = [
        "Audio"
        "Music"
        "AudioVideo"
      ];
      mimeTypes = [ "x-scheme-handler/orpheus" ];
    })
  ];
  meta = {
    description = "跨平台桌面音乐播放器，支持丰富歌词与多种音频格式（SPlayer 的下一代版本）";
    homepage = "https://github.com/SPlayer-Dev/SPlayer-Next";
    changelog = "https://github.com/SPlayer-Dev/SPlayer-Next/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "splayer-next";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
