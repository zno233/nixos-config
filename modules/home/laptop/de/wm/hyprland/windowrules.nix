{
  # 这个模块只需要 wayland.windowManager.hyprland.settings 属性
  wayland.windowManager.hyprland.settings = {

    windowrulev2 = [
      # --- Floating Apps (浮动应用) ---
      "float,class:^(Viewnior)$"
      "float,class:^(imv)$"
      "float,class:^(mpv)$"
      "float,title:^(Transmission)$"
      "float,title:^(Volume Control)$"
      "float,title:^(Firefox — Sharing Indicator)$"
      "float, title:^(Picture-in-Picture)$"
      "float,class:^(org.gnome.Calculator)$"
      "float,class:^(waypaper)$"
      "float,class:^(zenity)$"
      "float,class:^(org.gnome.FileRoller)$"
      "float,class:^(org.pulseaudio.pavucontrol)$"
      "float,class:^(SoundWireServer)$"
      "float,class:^(.sameboy-wrapped)$"
      "float,class:^(file_progress)$"
      "float,class:^(confirm)$"
      "float,class:^(dialog)$"
      "float,class:^(download)$"
      "float,class:^(notification)$"
      "float,class:^(error)$"
      "float,class:^(confirmreset)$"
      "float,title:^(Open File)$"
      "float,title:^(File Upload)$"
      "float,title:^(branchdialog)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"

      # --- Tiling/Pinning (平铺/置顶) ---
      "tile,class:^(Aseprite)$"
      "pin,class:^(rofi)$"
      "pin,class:^(waypaper)$"
      "pin, title:^(Picture-in-Picture)$"

      # --- Sizing and Moving (尺寸和位置) ---
      "move 0 0,title:^(Firefox — Sharing Indicator)$"
      "size 700 450,title:^(Volume Control)$"
      "move 40 55%,title:^(Volume Control)$"
      "size 850 500,class:^(zenity)$"
      "size 725 330,class:^(SoundWireServer)$"

      # --- Opacity (不透明度) ---
      "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
      "opacity 1.0 override 1.0 override, title:^(.*imv.*)$"
      "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
      "opacity 1.0 override 1.0 override, class:(Aseprite)"
      "opacity 1.0 override 1.0 override, class:(Unity)"
      "opacity 1.0 override 1.0 override, class:(zen)"
      "opacity 1.0 override 1.0 override, class:(evince)"

      # --- Workspace Assignment (工作区分配) ---
      "workspace 1, class:^(zen-beta)$"
      "workspace 3, class:^(evince)$"
      "workspace 4, class:^(Gimp-2.10)$"
      "workspace 4, class:^(Aseprite)$"
      "workspace 5, class:^(Audacious)$"
      "workspace 5, class:^(Spotify)$"
      "workspace 8, class:^(com.obsproject.Studio)$"
      "workspace 10, class:^(discord)$"
      "workspace 10, class:^(WebCord)$"

      # --- Idle Inhibition (防止休眠) ---
      "idleinhibit focus, class:^(mpv)$"
      "idleinhibit fullscreen, class:^(firefox)$"

      # --- XWayland Video Bridge (视频桥接 - 通常用于屏幕共享) ---
      "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "maxsize 1 1,class:^(xwaylandvideobridge)$"
      "noblur,class:^(xwaylandvideobridge)$"

      # --- Single Window/No Gaps Rules (单个窗口/无缝规则) ---
      "bordersize 0, floating:0, onworkspace:w[t1]"
      "rounding 0, floating:0, onworkspace:w[t1]"
      "bordersize 0, floating:0, onworkspace:w[tg1]"
      "rounding 0, floating:0, onworkspace:w[tg1]"
      "bordersize 0, floating:0, onworkspace:f[1]"
      "rounding 0, floating:0, onworkspace:f[1]"

      # --- Chromium Context Menu Fixes (Chromium 右键菜单修复) ---
      "opaque,class:^()$,title:^()$"
      "noshadow,class:^()$,title:^()$"
      "noblur,class:^()$,title:^()$"
    ];

    layerrule = [
      # --- Layer Rules (层规则) ---
      "dimaround, vicinae"
      "dimaround, rofi"
      "dimaround, swaync-control-center"
      
      # 新增：Waybar 模糊
      "blur, waybar"
      "ignorealpha 0.5, waybar"  # 可选：忽略低透明度像素，提升性能
      "xray 1, waybar"           # 可选：启用 xray 模式，模糊更精准
      
    ];

    workspace = [
      # --- Workspace Gaps (工作区间隙，用于实现无缝工作区) ---
      "w[t1], gapsout:0, gapsin:0"
      "w[tg1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];
  };
}
