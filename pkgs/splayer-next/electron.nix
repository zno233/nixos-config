{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  asar,
  nodejs,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron_43,
  writeShellScript,
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

  # 参考 nixpkgs 的 pkgs/by-name/sp/splayer：只取 .deb 里的应用代码，
  # 运行时改用 nixpkgs 的 electron（与 .deb 内置版本同为 43.2.0，ABI 一致），
  # GPU/EGL/Vulkan 加速、Wayland 支持全部由 nixpkgs electron 负责，
  # 无需 autoPatchelfHook 与打包驱动修补。
  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs = [
    dpkg
    asar
    nodejs
    makeWrapper
    copyDesktopItems
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" unpacked

    mkdir -p $out/share/splayer-next/resources

    # 解包 app.asar（自写脚本，跳过头部标记 unpacked 但 .deb 缺失的
    # darwin/win32 等其他平台文件，`asar extract` 会因此崩溃）。
    # 换用 nixpkgs electron 后 process.resourcesPath 会指向 electron 自带目录，
    # 而应用靠它加载 native/（audio-engine、media-ctrl）等原生模块与
    # electron-updater 元数据，故把 asar 内全部 resourcesPath 引用改写为
    # 本包资源目录（nixpkgs splayer 在源码层做同样的事）。
    NODE_PATH='${asar}/lib/node_modules' node ${./asar-extract.js} \
      unpacked/opt/SPlayer-Next/resources/app.asar app.asar.src
    # 把原 .unpacked 内容合并回解包树，重新打包时按同样规则拆出，
    # 保证 .node 原生模块以真实文件形式落在 app.asar.unpacked 里（asar 内无法 dlopen）。
    cp -r unpacked/opt/SPlayer-Next/resources/app.asar.unpacked/. app.asar.src/
    grep -rl "process.resourcesPath" app.asar.src | \
      xargs -r sed -i "s|process.resourcesPath|'$out/share/splayer-next/resources'|g"
    asar pack --unpack-dir "**/node_modules/**" --unpack "**/*.node" \
      app.asar.src $out/share/splayer-next/resources/app.asar

    # 保留运行期需要的资源（原生模块、electron-updater 元数据）
    cp -r unpacked/opt/SPlayer-Next/resources/native $out/share/splayer-next/resources/
    cp unpacked/opt/SPlayer-Next/resources/package-type $out/share/splayer-next/resources/ 2>/dev/null || true
    cp unpacked/opt/SPlayer-Next/resources/app-update.yml $out/share/splayer-next/resources/ 2>/dev/null || true

    install -Dm444 unpacked/usr/share/icons/hicolor/512x512/apps/SPlayer-Next.png \
      $out/share/icons/hicolor/512x512/apps/splayer-next.png

    makeWrapper '${lib.getExe electron_43}' $out/bin/splayer-next \
      --add-flags $out/share/splayer-next/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

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
  # 自动更新：update.sh 会同步本包与 default.nix 的 version 及两个平台 hash。
  # 用法：./pkgs/splayer-next/update.sh（在仓库任意位置）
  passthru.updateScript = {
    command = [
      (writeShellScript "splayer-next-update" ''
        exec "$(git rev-parse --show-toplevel)/pkgs/splayer-next/update.sh"
      '')
    ];
  };
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