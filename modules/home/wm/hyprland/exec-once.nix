{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    # D-Bus/Systemd 环境变量：保留，确保 Wayland/QT/Electron 应用正常运行
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment QT_SCALE_FACTOR ELECTRON_OZONE_PLATFORM_HINT"

    # Caelestia Shell 通常包含自己的锁屏逻辑，故注释掉
     "hyprlock" 
    
    # 系统级 Applets/Daemon
    "nm-applet &"
    "poweralertd &"
    "blueman-applet &" 
    
    # 剪贴板管理器
     "wl-clip-persist --clipboard both &" 
     "wl-paste --watch cliphist store &" 
    
    # 桌面面板
    "waybar &" 
    
    # 通知中心
     "swaync &" 
    
     "vicinae server &" 
    
    # 系统级 Daemon
    "udiskie --automount --notify --smart-tray &"
    "hyprctl setcursor Bibata-Modern-Ice 24 &"
    "init-wallpaper &"

    # 应用启动
    "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
    "[workspace 1 silent] zen-beta"
    "[workspace 2 silent] kitty"
    
    # 启动 Caelestia Shell
    #"caelestia-shell -d &"
  ];
}
