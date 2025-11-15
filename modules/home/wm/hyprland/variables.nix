{ config, pkgs, lib, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    # 在 hyprland.conf 开头添加这些 env 行
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = XDG_SESSION_TYPE,wayland
    env = XDG_SESSION_DESKTOP,Hyprland
    env = GDK_BACKEND,wayland,x11
    env = QT_QPA_PLATFORM,wayland;xcb
    env = QT_AUTO_SCREEN_SCALE_FACTOR,1
    env = QT_QPA_PLATFORMTHEME,qt6ct
    env = QT_QPA_PLATFORMTHEME_5,qt5ct
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
    env = ELECTRON_OZONE_PLATFORM_HINT,auto
    env = NIXOS_OZONE_WL,1
    env = MOZ_ENABLE_WAYLAND,1
    env = SDL_VIDEODRIVER,wayland,x11
    env = CLUTTER_BACKEND,wayland
    env = _JAVA_AWT_WM_NONREPARENTING,1
  '';
  home.sessionVariables = {
    # ====================================
    # 核心 Wayland 与桌面环境设置
    # ====================================
   
    # 告诉程序我们正在使用 Hyprland 和 Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
   
    # GDK/GTK 后端设置，优先使用 Wayland
    GDK_BACKEND = "wayland,x11";
   
    # ====================================
    # Qt 应用分数缩放与优化 (Qt5 & Qt6)
    # ====================================
   
    # 告诉 Qt 优先使用 Wayland 后端，如果不行则退回到 XCB
    QT_QPA_PLATFORM = "wayland;xcb";
   
    # 启用 Qt 自动缩放（移除固定缩放因子，依赖 Hyprland monitor 配置处理分数缩放）
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
   
    # 主题设置
    QT_QPA_PLATFORMTHEME = "qt6ct"; # 针对 Qt6 应用
    QT_QPA_PLATFORMTHEME_5 = "qt5ct"; # 针对 Qt5 应用
   
    # 禁用 Qt 应用的客户端装饰（CWD），让 Hyprland 来处理边框和阴影
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
   
    # ====================================
    # Electron (QQ/微信等) 优化
    # ====================================
   
    # 强制 Electron 应用使用 Wayland/Ozone 平台（改善缩放和模糊问题）
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
   
    # (NixOS 特定) 确保 Electron 应用在 NixOS 环境中启用 Wayland/Ozone 支持
    NIXOS_OZONE_WL = "1";
   
    # ====================================
    # 兼容性与其他应用优化
    # ====================================
   
    # 强烈推荐：启用 Firefox/Mozilla 的 Wayland 后端 (提升性能和 HiDPI 缩放)
    MOZ_ENABLE_WAYLAND = "1";
   
    # 针对旧的 SDL 游戏或应用，优先使用 Wayland
    SDL_VIDEODRIVER = "wayland,x11";
   
    # 针对 Clutter 库应用，优先使用 Wayland
    CLUTTER_BACKEND = "wayland";
   
    # 针对 Java AWT 应用程序，改善窗口重绘/显示问题
    _JAVA_AWT_WM_NONREPARENTING = "1";
   
  };
}
