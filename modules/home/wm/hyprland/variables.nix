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
}
