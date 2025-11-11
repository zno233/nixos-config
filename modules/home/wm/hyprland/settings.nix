{
  # 完整的 Hyprland 配置，可以直接合并到您的 home-manager 或 NixOS 配置中。
  # 
  # 假设您在 Nix 代码的其他地方启用了 Hyprland 模块，例如:
  # programs.hyprland.enable = true;
  
  wayland.windowManager.hyprland.settings = {

    input = {
      kb_layout = "us,fr";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      repeat_delay = 300;
      follow_mouse = 0;
      float_switch_override_focus = 0;
      mouse_refocus = 0;
      sensitivity = 0;
      touchpad = {
        natural_scroll = true;
      };
    };
    
   gestures = {
      gesture = [
        "3, horizontal, workspace" # 启用三指水平滑动切换工作区
      ];
    };

    general = {
      # 注意：Hyprland 变量 $mainMod 在 Nix 中需要用引号括起来
      "$mainMod" = "SUPER";
      layout = "dwindle";
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      "col.active_border" = "0xff5e81ac 0xff88c0d0 45deg";
      "col.inactive_border" = "0x66333333";
      no_border_on_floating = false;
    };

    misc = {
      disable_hyprland_logo = true;
      always_follow_on_dnd = true;
      layers_hog_keyboard_focus = true;
      animate_manual_resizes = false;
      enable_swallow = true;
      focus_on_activate = true;
      new_window_takes_over_fullscreen = 2;
      middle_click_paste = false;
    };

    dwindle = {
      force_split = 2;
      special_scale_factor = 1.0;
      split_width_multiplier = 1.0;
      use_active_for_splits = true;
      # 注意：Hyprland 配置中的 "yes" 字符串在 Nix 中需要引号
      pseudotile = "yes";
      preserve_split = "yes";
    };

    master = {
      new_status = "master";
      special_scale_factor = 1;
    };

    decoration = {
      rounding = 18;

      blur = {
        enabled = true;
        size = 6;
        passes = 3;
        brightness = 1;
        contrast = 1.4;
        ignore_opacity = true;
        noise = 0;
        new_optimizations = true;
        xray = true;
      };

      shadow = {
        enabled = true;
        ignore_window = true;
        offset = "0 2";
        range = 20;
        render_power = 3;
        color = "rgba(00000055)";
      };
    };

    animations = {
      enabled = true;
    };

    # 自定义贝塞尔曲线
    bezier = [
      "specialWorkSwitch, 0.05, 0.7, 0.1, 1"
      "emphasizedAccel, 0.3, 0, 0.8, 0.15"
      "emphasizedDecel, 0.05, 0.7, 0.1, 1"
      "standard, 0.2, 0, 0, 1"
    ];

    # 动画配置
    animation = [
      "layersIn, 1, 5, emphasizedDecel, slide"
      "layersOut, 1, 4, emphasizedAccel, slide"
      "fadeLayers, 1, 5, standard"

      "windowsIn, 1, 5, emphasizedDecel"
      "windowsOut, 1, 3, emphasizedAccel"
      "windowsMove, 1, 6, standard"
      "workspaces, 1, 5, standard"

      "specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%"

      "fade, 1, 6, standard"
      "fadeDim, 1, 6, standard"
      "border, 1, 6, standard"
    ];

    xwayland = {
      force_zero_scaling = true;
    };
  };
}
