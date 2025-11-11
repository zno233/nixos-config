{ config, ... }:
let
  # --- 1. Base16 Aurora 调色板颜色定义 ---
  base00 = "09030B"; # Background
  base01 = "100518"; # Lighter Background (Tooltip BG)
  base04 = "78598D"; # Lighter Foreground (Empty Workspaces)
  base05 = "A6A2A4"; # Foreground (Default Text)
  base06 = "E8DCD1"; # Brighter Foreground (Network Icon)
  base07 = "F8F8F0"; # Brightest Foreground (Tooltip Border, Inactive Workspaces)
  base08 = "BD0952"; # Red (Critical Battery, Power Menu)
  base0A = "E6C218"; # Yellow (Volume Icon, Launcher)
  base0B = "18A121"; # Green (Battery Gradient 1)
  base0D = "238DC0"; # Blue (Backlight, Charging/Full Gradient 2)
  base0E = "78598D"; # Magenta (Memory, Clock, Active Workspaces, Charging/Full Gradient 1)
  base0F = "7755B8"; # Cyan (Battery Gradient 2)
  trayBackgroundColor = "#${base00}";
  mainMonitorName = "eDP-1";
  # --- 2. Waybar 模块配置 (JSONC 字符串) ---
  moduleConfiguration =
    # jsonc
    ''
      "custom/launcher" : {
        "format" : "<span foreground='#${base0A}'></span>",
        "on-click" : "random-wallpaper",
        "on-click-right" : "rofi -show drun",
        "tooltip" : "true",
        "tooltip-format" : "Random Wallpaper"
      },
      "custom/power-menu": {
        "tooltip": true,
        "tooltip-format": "Power menu",
        "format": "<span foreground='#${base08}'> </span>",
        "on-click": "power-menu"
      },
      "custom/notification": {
        "tooltip": true,
        "tooltip-format": "Notifications",
        "format": "{icon}",
        "format-icons": {
          "notification": "<span foreground='#${base08}'><sup></sup></span>",
          "none": "",
          "dnd-notification": "<span foreground='#${base08}'><sup></sup></span>",
          "dnd-none": "",
          "inhibited-notification": "<span foreground='#${base08}'><sup></sup></span>",
          "inhibited-none": "",
          "dnd-inhibited-notification": "<span foreground='#${base08}'><sup></sup></span>",
          "dnd-inhibited-none": ""
        },
        "return-type": "json",
        "exec-if": "which swaync-client",
        "exec": "swaync-client -swb",
        "on-click": "swaync-client -t -sw",
        "on-click-right": "swaync-client -d -sw",
        "escape": true
      },
      "hyprland/workspaces": {
        "format": "{icon}",
          "format-icons": {
          "default": ""
        }
      },
      "hyprland/window": {
        "format": "{}",
        "separate-outputs": true,
        "icon": true,
        "icon-size": 18
      },
     
      "clock": {
        "format": "<span foreground='#${base06}'>  </span>  {:%a %d %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "on-click": "kitty --class=clock,clock --title=clock -o remember_window_size=no -o initial_window_width=600 -o initial_window_height=200 -e tty-clock -s -c -C 5"
      },
      "cpu": {
        "format": "<span foreground='#${base0E}'> </span> {usage}%",
        "format-alt": "<span foreground='#${base0E}'> </span> {avg_frequency} GHz",
        "interval": 2,
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
      "memory": {
        "format": "<span foreground='#${base0E}'>󰟜 </span>{}%",
        "format-alt": "<span foreground='#${base0E}'>󰟜 </span>{used} GiB",
        "interval": 2,
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
      "network": {
        "format-wifi": "<span size='13000' foreground='#${base06}'>󰖩  </span>{essid}",
        "format-ethernet": "<span size='13000' foreground='#${base06}'>󰤭</span> Disconnected",
        "format-linked": "{ifname} (No IP) 󱚵",
        "format-disconnected": "<span size='13000' foreground='#${base06}'> </span>Disconnected",
        "tooltip-format-wifi": "Signal Strenght: {signalStrength}%",
        "on-click": "kitty --class nmtui,nmtui --title=nmtui -o remember_window_size=no -o initial_window_width=400 -o initial_window_height=400 -e doas nmtui"
      },
      "pulseaudio": {
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-right" : "pavucontrol",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-",
        "format": "<span size='13000' foreground='#${base0A}'>{icon}  </span>{volume}%",
        "format-muted": "<span size='13000' foreground='#${base0A}'>  </span>Muted",
        "format-icons": {
          "headphone": "󱡏",
          "hands-free": "",
          "headset": "󱡏",
          "phone": "",
          "portable": "",
          "car": "",
          "default": [
            "󰕿",
            "󰖀",
            "󰕾",
            "󰕾"
          ]
        }
      },
      "backlight": {
        "device": "intel_backlight",
        "on-scroll-up": "light -A 1",
        "on-scroll-down": "light -U 1",
        "format": "<span size='13000' foreground='#${base0D}'>{icon} </span>  {percent}%",
        "format-icons": [
          "",
          ""
        ]
      },
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "<span size='13000' foreground='#${base0E}'>{icon}  </span>{capacity}%",
        "format-warning": "<span size='13000' foreground='#${base0E}'>{icon}  </span>{capacity}%",
        "format-critical": "<span size='13000' foreground='#${base08}'>{icon}  </span>{capacity}%",
        "format-charging": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
        "format-plugged": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
        "format-alt": "<span size='13000' foreground='#${base0E}'>{icon} </span>{time}",
        "format-full": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
        "format-icons": [
          "",
          "",
          "",
          "",
          ""
        ],
        "tooltip-format": "{time}",
        "interval": 5
      },
     
      "tray": {
        "icon-size": 16,
        "spacing": 10
      }
    '';
in
{
  programs.waybar = {
    enable = true;
  };
  home.file = {
    # --- 3. Waybar 主配置文件: config.jsonc (仅包含主显示器) ---
    ".config/waybar/config.jsonc".text =
      # json
      ''
        [
          {
            "position": "top",
            "layer": "top",
            "output": "${mainMonitorName}",
            "modules-left": [
              "custom/launcher",
              "hyprland/workspaces",
              "hyprland/window"
            ],
            "modules-center": [
              "clock",
              "cpu",
              "memory"
            ],
            "modules-right": [
              "tray",
              "network",
              "pulseaudio",
              "backlight",
              "custom/notification",
              "battery",
              "custom/power-menu"
            ],
            ${moduleConfiguration}
          }
        ]
      '';
    # --- 4. CSS 颜色定义: colors.css ---
    ".config/waybar/colors.css".text =
      # css
      ''
        @define-color base00 #${base00};
        @define-color base01 #${base01};
        @define-color base04 #${base04};
        @define-color base05 #${base05};
        @define-color base06 #${base06};
        @define-color base07 #${base07};
        @define-color base08 #${base08};
        @define-color base0A #${base0A};
        @define-color base0B #${base0B};
        @define-color base0D #${base0D};
        @define-color base0E #${base0E};
        @define-color base0F #${base0F};
      '';
    # --- 5. 托盘样式: tray.css ---
    ".config/waybar/tray.css".text =
      # css
      ''
        #tray {
          background: rgba(9, 3, 11, 0.9);
        }
      '';
    # --- 6. 动画样式: animation.css ---
    ".config/waybar/animation.css".text =
      # css
      ''
        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 30%; }
          100% { background-position: 0% 50%; }
        }
        @keyframes gradient_f {
          0% { background-position: 0% 200%; }
          50% { background-position: 200% 0%; }
          100% { background-position: 400% 200%; }
        }
        @keyframes gradient_f_nh {
          0% { background-position: 0% 200%; }
          100% { background-position: 200% 200%; }
        }
        @keyframes gradient_rv {
          0% { background-position: 200% 200%; }
          100% { background-position: 0% 200%; }
        }
      '';
    # --- 7. 主样式: style.css (精确修正和最终样式) ---
    ".config/waybar/style.css".text =
  # css
  ''
    @import "animation.css";
    @import "colors.css";
    @import "tray.css";
    * {
      font-size: 14px;
      font-family: "Hug Me Tight", "Xiaolai SC";
      min-height: 0;
    }
    window#waybar {
      background: rgba(9, 3, 11, 0.65);
      border-radius: 16px;
      border: 1px solid rgba(120, 89, 141, 0.3);
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.45);
      margin: 12px 16px;
      padding: 0 8px;
    }
    #workspaces, #window, #clock, #cpu, #memory,
    #network, #pulseaudio, #backlight, #battery,
    #tray, #custom-launcher, #custom-power-menu,
    #custom-notification {
      background: transparent !important;
      box-shadow: none !important;
      border: none !important;
      margin: 0 6px !important;
      padding: 6px 10px !important;
      color: @base06;
      text-shadow: 0 0 8px rgba(0, 0, 0, 0.6);
      font-weight: 600;
    }
    #workspaces {
      background: transparent;
      margin-top: 10px;
      margin-bottom: 5px;
      margin-left: 15px;
      margin-right: 5px;
      padding: 6px 3px;
    }
    #workspaces button {
      background: rgba(168, 162, 164, 0.4);
      min-width: 12px; min-height: 12px;
      margin: 0 4px; border-radius: 50%;
      transition: all 0.25s cubic-bezier(0.55, -0.68, 0.48, 1.682);
    }
    #workspaces button.active {
      background: @base0E;
      min-width: 36px; border-radius: 20px;
    }
    #workspaces button.empty { background: @base04; }
    #window {
      background: rgba(248, 248, 240, 0.1);
      border: 1px solid rgba(120, 89, 141, 0.4);
      border-radius: 12px;
      padding: 4px 10px;
      margin-top: 10px;
      margin-bottom: 5px;
      margin-left: 5px;
      margin-right: 5px;
      color: @base06;
      text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.9),
                   -1px -1px 3px rgba(0, 0, 0, 0.9);
      transition: all 0.3s cubic-bezier(0.55, -0.68, 0.48, 1.682);
    }
    window#waybar.empty #window { background: none; border: none; box-shadow: none; }
    #battery {
      padding: 4px 10px;
      border-radius: 10px;
      box-shadow: 1px 2px 2px #101010;
      text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
      margin-top: 10px;
      margin-bottom: 5px;
      margin-left: 5px;
      margin-right: 15px;
      background: linear-gradient(
        118deg,
        @base0B 5%,
        @base0F 5%,
        @base0F 20%,
        @base0B 20%,
        @base0B 40%,
        @base0F 40%,
        @base0F 60%,
        @base0B 60%,
        @base0B 80%,
        @base0F 80%,
        @base0F 95%,
        @base0B 95%
      );
      background-size: 200% 300%;
      animation: gradient_f_nh 4s linear infinite;
      color: @base01;
    }
    #battery.charging, #battery.plugged {
      background: linear-gradient(
        118deg,
        @base0E 5%,
        @base0D 5%,
        @base0D 20%,
        @base0E 20%,
        @base0E 40%,
        @base0D 40%,
        @base0D 60%,
        @base0E 60%,
        @base0E 80%,
        @base0D 80%,
        @base0D 95%,
        @base0E 95%
      );
      background-size: 200% 300%;
      animation: gradient_rv 4s linear infinite;
    }
    #battery.full { animation: gradient_rv 20s linear infinite; }
    #tray { background: transparent; padding: 0 8px; margin: 0 6px; }
    #tray > .passive { -gtk-icon-effect: dim; }
    #tray > .needs-attention { -gtk-icon-effect: highlight; }
    tooltip {
      background: @base01;
      border-radius: 5px;
      border-width: 2px;
      border-style: solid;
      border-color: @base07;
    }
  '';
  };
}
