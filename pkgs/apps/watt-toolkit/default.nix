# 职责: Watt Toolkit (原 Steam++) 官方预编译产物重打包.
# 思路: 保留上游自带 .NET runtime 整体部署到 $out/opt, 不用 nixpkgs dotnet 替换
# (版本耦合 AspNetCore.App 10.0.4); ELF 的 NEEDED 交给 autoPatchelf,
# 而 .NET/Avalonia 在运行时 dlopen 的库 (ICU/OpenSSL/X11/GL/GTK, 无 NEEDED 条目,
# autoPatchelf 不可见) 统一由 wrapper 的 LD_LIBRARY_PATH 提供.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  # 网络加速环境检查依赖 (上游 environment_check.sh 检测项, 缺失即弹
  # 「请在终端手动运行 environment_check.sh 安装依赖环境」):
  nssTools, # 提供 certutil — 初始化 ~/.pki/nssdb 并导入 SteamTools 自签 CA
  jq, # 解析更新接口
  zenity, # 图形提示
  # ELF NEEDED 或运行时 dlopen 所需 (见下方 dlopenLibs 与 buildInputs 注释):
  icu,
  openssl,
  fontconfig, # libSkiaSharp.so 的 NEEDED
  gtk3,
  libglvnd, # libGL.so.1 (Avalonia GLX/Skia)
  libice, # libICE.so.6 (Avalonia X11 ICE)
  libsm, # libSM.so.6
  vulkan-loader, # libvulkan.so.1 (Avalonia 可选渲染后端)
  libx11,
  libxcursor,
  libxrandr,
  libxi,
  libxext,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    # .NET/Avalonia 托管代码在运行时按名 dlopen 的库 (无 NEEDED 条目, autoPatchelf
    # 看不见), SSOT — 派生两处用途: wrapper 的 LD_LIBRARY_PATH (主用途, 见 preFixup)
    # 与 buildInputs 尾部 (让 autoPatchelf 一并搜索, 当前无 NEEDED 引用, 属防御性保留).
    # - icu: .NET 10 的 ICU shim 只 dlopen 无版本后缀的 libicuuc.so/libicui18n.so,
    #   nixpkgs icu 的 out/lib 恰好带有这两个无版本符号链接
    # - openssl: System.Security.Cryptography.Native.OpenSsl 运行时 dlopen libssl.so.3
    # - libglvnd / vulkan-loader: libGL.so.1 / libvulkan.so.1
    # - libice / libsm: libICE.so.6 / libSM.so.6 (漏掉即 DllNotFoundException)
    # - x11 系 + gtk3: Avalonia X11 后端按名 dlopen (见程序集内字符串)
    dlopenLibs = [
      icu
      openssl
      gtk3
      libglvnd
      libice
      libsm
      vulkan-loader
      libx11
      libxcursor
      libxrandr
      libxi
      libxext
    ];

    # 网络加速运行时工具 (environment_check.sh -c 检测项), 经 wrapper --prefix PATH
    # 注入: 应用内 AcceleratorPageViewModel.EnvironmentCheck 用 /bin/bash 执行
    # <BaseDirectory>/script/environment_check.sh -c, 仅当 command -v certutil
    # 成功才 exit 200 放行, 否则弹「请在终端手动运行 environment_check.sh」.
    # ~/.pki/nssdb 初始化由 wrapper --run 幂等完成 (与应用内 certutil 调用同样
    # 使用无 sql: 前缀的路径形式, 保持同一数据库).
    runtimeTools = [
      nssTools # certutil
      jq
      zenity
    ];
  in
  {
    pname = "watt-toolkit-bin";
    version = "3.1.0";

    src = fetchurl {
      # 上游 URL 中 "++" 需编码为 %2B%2B
      url = "https://github.com/BeyondDimension/SteamTools/releases/download/${finalAttrs.version}/Steam%2B%2B_v${finalAttrs.version}_linux_x64.tgz";
      # SRI (base64) 形式; 等价的 nix-base32 为
      # 0gvq85550gl7s91ssrm85761d6p1ky0hiy80hwi4kikazbabr6gv (hex: fb99bcd4...)
      hash = "sha256-+5m81PpqxkkihwD5CIGf4ZoWzCmoZq1D0oc+UEpBeD8=";
    };

    strictDeps = true;
    # tgz 无单一顶层目录 (assemblies/ dotnet/ ... 平铺), 显式锚定 sourceRoot
    sourceRoot = ".";
    dontBuild = true;
    dontConfigure = true;
    # lttng-ust >= 2.14 起 soname 升为 liblttng-ust.so.1 (ABI 破坏), 而上游的
    # libcoreclrtraceptprovider.so 仍 NEED 旧 soname liblttng-ust.so.0, nixpkgs
    # 中已无满足者. 该 provider 仅在开启 LTTng 追踪会话时才会被 coreclr dlopen,
    # 对桌面使用无影响, 故显式豁免 (悬空 NEEDED 只影响按需加载的那一次).
    autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = [
      (lib.getLib stdenv.cc.cc) # libstdc++.so.6 / libgcc_s.so.1
      fontconfig # libSkiaSharp.so 的 NEEDED
    ]
    ++ dlopenLibs;

    desktopItems = [
      (makeDesktopItem {
        name = "watt-toolkit";
        desktopName = "Watt Toolkit";
        exec = "watt-toolkit";
        icon = "watt-toolkit";
        # 实测上游 Avalonia 窗口的 WM_CLASS (Xvfb + xwininfo 取证)
        startupWMClass = "Steam++";
        comment = "Cross-platform toolbox for Steam (formerly Steam++)";
        categories = [
          "Utility"
          "Game"
        ];
      })
    ];

    installPhase = ''
      runHook preInstall

      install -dm755 $out/opt/watt-toolkit
      # script/environment_check.sh 必须装: 应用「网络加速/安装证书」前用
      # /bin/bash 执行 <BaseDirectory>/script/environment_check.sh -c,
      # exit 200 (certutil 存在) 才放行, 否则弹「请在终端手动运行
      # environment_check.sh 安装依赖环境」
      cp -r assemblies dotnet modules native Icons $out/opt/watt-toolkit/
      install -Dm755 script/environment_check.sh \
        $out/opt/watt-toolkit/script/environment_check.sh
      # 替代上游 Steam++.sh (上游会在安装目录建 Steam++ -> dotnet 符号链接,
      # store 只读做不到); 应用安装证书时 pkexec <BaseDirectory>/Steam++.sh
      # linux -ceri ... 以 root 执行系统侧信任, 故必须存在
      printf '%s\n' \
        '#!/bin/sh' \
        'run_path="$(dirname "$0")"' \
        'export DOTNET_ROOT="$run_path/dotnet"' \
        'exec "$run_path/dotnet/dotnet" "$run_path/assemblies/Steam++.dll" "$@"' \
        > $out/opt/watt-toolkit/Steam++.sh
      chmod 755 $out/opt/watt-toolkit/Steam++.sh

      # tar 内文件权限均为 0700, 补齐 store 负载所需的世界可读位
      chmod -R u+rwX,go+rX $out/opt/watt-toolkit

      install -Dm644 Icons/Watt-Toolkit.png \
        $out/share/icons/hicolor/512x512/apps/watt-toolkit.png

      runHook postInstall
    '';

    preFixup = ''
      makeWrapper $out/opt/watt-toolkit/dotnet/dotnet $out/bin/watt-toolkit \
        --set DOTNET_ROOT $out/opt/watt-toolkit/dotnet \
        --prefix PATH : ${lib.makeBinPath runtimeTools} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dlopenLibs}:$out/opt/watt-toolkit/native/linux-x64 \
        --run '${nssTools}/bin/certutil -d $HOME/.pki/nssdb -L >/dev/null 2>&1 || { mkdir -p -m 700 $HOME/.pki/nssdb; ${nssTools}/bin/certutil -d $HOME/.pki/nssdb -N --empty-password; }' \
        --add-flags $out/opt/watt-toolkit/assemblies/Steam++.dll
    '';

    meta = {
      description = "Cross-platform toolbox for Steam (formerly Steam++)";
      longDescription = ''
        Watt Toolkit is a cross-platform Steam toolbox supporting account
        switching, authenticator, network acceleration and more. This package
        repackages the official prebuilt release with its bundled .NET runtime.
      '';
      homepage = "https://steampp.net";
      changelog = "https://github.com/BeyondDimension/SteamTools/releases/tag/${finalAttrs.version}";
      license = lib.licenses.gpl3Only;
      mainProgram = "watt-toolkit";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  }
)
