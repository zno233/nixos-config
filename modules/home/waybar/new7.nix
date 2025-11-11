{ config, ... }:
let
  # --- 1. 硬编码 Base16 Aurora 调色板颜色定义 ---
  base00 = "09030B"; # Background
  base01 = "100518"; # Lighter Background (Tooltip BG)
  base04 = "78598D"; # Lighter Foreground (Empty Workspaces)
  base05 = "A6A2A4"; # Foreground (Default Text)
  base06 = "5E81AC"; # Brighter Foreground (Network Icon)
  base07 = "F8F8F0"; # Brightest Foreground (Tooltip Border, Inactive Workspaces)
  base08 = "BD0952"; # Red (Critical Battery, Power Menu)
  base0A = "E6C218"; # Yellow (Volume Icon, Launcher)
  base0B = "18A121"; # Green (Battery Gradient 1)
  base0D = "238DC0"; # Blue (Backlight, Charging/Full Gradient 2)
  base0E = "78598D"; # Magenta (Memory, Clock, Active Workspaces, Charging/Full Gradient 1)
  base0F = "7755B8"; # Cyan (Battery Gradient 2)
  base0G = "81A1C1";
  base0H = "fb958b";
  trayBackgroundColor = "#${base00}";
  # **硬编码主显示器名称**
  mainMonitorName = "eDP-1";
  # --- 2. 模块配置 (Module Definitions) ---
  moduleConfiguration =
    # jsonc
    ''
      // Modules configuration
      "custom/launcher" : {
        "format" : "<span foreground='#${base0A}'></span>",
        "on-click" : "random-wallpaper",
        "on-click-right" : "rofi -show drun",
        "tooltip" : "true",
        "tooltip-format" : "Random Wallpaper",
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
     
      "cpu": {
        "format": "<span foreground='#fb958b'> </span> {usage}%",
        "format-alt": "<span foreground='#fb958b'> </span> {avg_frequency} GHz",
        "interval": 2,
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
     
      "hyprland/workspaces": {
          "on-click": "activate",  
          "format": "{icon}",
          "format-icons": {
               "active": "󰮯",
               "default": "",
               //"empty": ""
          },
      },

      "hyprland/window": {
        "format": "{}",
        "separate-outputs": true,
        "icon": true,
        "icon-size": 18
      },
      "memory": {
        "format": "<span foreground='#a1c999'>󰟜 </span>{}%",
        "format-alt": "<span foreground='#a1c999'>󰟜 </span>{used} GiB",
        "interval": 2,
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
      "backlight": {
        "device": "intel_backlight",
        "on-scroll-up": "light -A 1",
        "on-scroll-down": "light -U 1",
        "format": "<span size='13000' foreground='#${base0D}'>{icon} </span> {percent}%",
        "format-icons": [
          "",
          ""
        ]
      },
      "tray": {
        "icon-size": 16,
        "spacing": 10
      },
      "clock": {
        "format": "<span foreground='#${base06}'> </span> {:%a %d %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "on-click": "kitty --class=clock,clock --title=clock -o remember_window_size=no -o initial_window_width=600 -o initial_window_height=200 -e tty-clock -s -c -C 5"
      },
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15,
        },
        "format": "<span size='13000' foreground='#${base0E}'>{icon} </span>{capacity}%",
        "format-warning": "<span size='13000' foreground='#${base0E}'>{icon} </span>{capacity}%",
        "format-critical": "<span size='13000' foreground='#${base08}'>{icon} </span>{capacity}%",
        "format-charging": "<span size='13000' foreground='#${base0E}'> </span>{capacity}%",
        "format-plugged": "<span size='13000' foreground='#${base0E}'> </span>{capacity}%",
        "format-alt": "<span size='13000' foreground='#${base0E}'>{icon} </span>{time}",
        "format-full": "<span size='13000' foreground='#${base0E}'> </span>{capacity}%",
        "format-icons": [
          "", "", "", "", ""
        ],
        "tooltip-format": "{time}",
        "interval": 5
      },
      "network": {
        "format-wifi": "<span size='13000' foreground='#${base06}'>󰖩 </span>{essid}",
        "format-ethernet": "<span size='13000' foreground='#${base0A}}'>󰤭</span> Disconnected",
        "format-linked": "{ifname} (No IP) 󱚵",
        "format-disconnected": "<span size='13000' foreground='#${base0H}'> </span>Disconnected",
        "tooltip-format-wifi": "Signal Strenght: {signalStrength}%",
        "on-click": "kitty --class nmtui,nmtui --title=nmtui -o remember_window_size=no -o initial_window_width=400 -o initial_window_height=400 -e doas nmtui"
      },
      "pulseaudio": {
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-right" : "pavucontrol",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-",
        "format": "<span size='13000' foreground='#${base0G}'>{icon} </span>{volume}%",
        "format-muted": "<span size='13000' foreground='#${base0H}'> </span>Muted",
        "format-icons": {
          "headphone": "󱡏",
          "hands-free": "",
          "headset": "󱡏",
          "phone": "",
          "portable": "",
          "car": "",
          "default": [
            "󰕿", "󰖀", "󰕾", "󰕾"
          ]
        }
      },
      "group/meters": {
        "orientation": "inherit",
        "drawer": {
          "transition-duration": 500,
          "transition-left-to-right": false,
        },
        "modules": [
          "battery",
          "memory",
          "network",
          "pulseaudio",
          "backlight"
        ]
      }
    '';
in
{
  programs.waybar = {
    enable = true;
  };
  home.file = {
    # --- 3. 配置文件：config.jsonc (仅包含主显示器布局) ---
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
              "clock",
              "cpu",
              "memory"
            ],
            "modules-center": [
              "hyprland/window"
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
    # --- 4. 颜色定义：colors.css ---
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
    # --- 5. 托盘样式：tray.css (使用 base00) ---
    ".config/waybar/tray.css".text =
      # css
      ''
        #tray {
          background: alpha(@base00, 0.7);
        }
      '';
     # --- 6. 主样式：style.css (包含所有模块的视觉样式) ---
    ".config/waybar/style.css".text =
      # css
      ''
        @import "animation.css";
        @import "colors.css";
        @import "tray.css";
        * {
          /* all: unset; */
          font-size: 14px;
          font-family: "Maple Mono", "lxgw-wenkai";
          min-height: 0;
        }
        window#waybar {
          background-color: rgba(26, 27, 38, 0.5); /* 目标颜色 */
          color: #ffffff;
          transition-property: all;
          transition-duration: 0.5s;
        }
        window#waybar.hidden {
          opacity: 0.1;
        }
        tooltip {
          background: @base01;
          border-radius: 5px;
          border-width: 2px;
          border-style: solid;
          border-color: @base07;
        }
        /* --------------------------------- 通用模块样式 (深色背景，圆角，阴影) --------------------------------- */
        #network,
        #clock,
        #pulseaudio,
        #backlight,
        #memory,
        #tray,
        #cpu,
        #custom-launcher,
        #custom-power-menu,
        #custom-notification
        {
          color: #e5e5e5;
          border-radius: 8px;
          padding: 2px 10px;
          background-color: #252733; 
          margin-left: 4px;
          margin-right: 4px;
          margin-top: 8.5px;
          margin-bottom: 8.5px;
          
          text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
        }
        /* --------------------------------- Hyprland/workspaces 样式 (#workspaces) --------------------------------- */
        #workspaces {
          background: transparent;
          box-shadow: none;
          border-radius: 0px;
          margin-top: 8.5px;
          margin-bottom: 8.5px;
          margin-left: 5px;
          margin-right: 5px;
         
          font-size: 0px;
          padding: 2px 3px;
        }
        #workspaces button {
         font-size: 0px;
          padding: 0px 1px;
          margin: 0px 4px;
          border-radius: 20px;
          transition: all 0.25s cubic-bezier(0.55, -0.68, 0.48, 1.682);
          color: #7a95c9;
        }
        #workspaces button.active {
          font-size: 1px;
          border-radius: 20px;
          min-width: 30px;
          background-size: 400% 400%;
          color: #ecd3a0;
        }
        /* --------------------------------- Hyprland/window 样式 (#window) --------------------------------- */
        #window {
          background: transparent;
          box-shadow: none;
         
          border: 1px solid #7a95c9; /* 保持线条边框 */
          border-radius: 10px;
         
          padding: 2px 10px;
          margin-top: 8.5px;
          margin-bottom: 8.5px;
          margin-left: 5px;
          margin-right: 5px;
         
          color: #ecd3a0;
         
          text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.9),
                       -1px -1px 3px rgba(0, 0, 0, 0.9);
                      
          transition: all 0.3s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }
        window#waybar.empty #window {
          border: none;
          background: none;
          background-color: transparent;
          box-shadow: none;
        }
        /* --------------------------------- battery 样式 (渐变背景) --------------------------------- */
        #battery {
          padding: 2px 10px;
          border-radius: 10px;
          box-shadow: 1px 2px 2px #101010;
          text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
          margin-top: 8.5px;
          margin-bottom: 8.5px;
          margin-left: 5px;
          margin-right: 5px;
         
          background: @base0F;
          background: linear-gradient(
            118deg,
            @base0B 5%, @base0F 5%,
            @base0F 20%, @base0B 20%,
            @base0B 40%, @base0F 40%,
            @base0F 60%, @base0B 60%,
            @base0B 80%, @base0F 80%,
            @base0F 95%, @base0B 95% 
          );
          background-size: 200% 300%;
          animation: gradient_f_nh 4s linear infinite;
          color: @base01;
        }
        #battery.charging,
        #battery.plugged {
          background: linear-gradient(
            118deg,
            @base0E 5%, @base0D 5%,
            @base0D 20%, @base0E 20%,
            @base0E 40%, @base0D 40%,
            @base0D 60%, @base0E 60%,
            @base0E 80%, @base0D 80%,
            @base0D 95%, @base0E 95%
          );
          background-size: 200% 300%;
          animation: gradient_rv 4s linear infinite;
        }
        #battery.full {
          background: linear-gradient(
            118deg,
            @base0E 5%, @base0D 5%,
            @base0D 20%, @base0E 20%,
            @base0E 40%, @base0D 40%,
            @base0D 60%, @base0E 60%,
            @base0E 80%, @base0D 80%,
            @base0D 95%, @base0E 95%
          );
          background-size: 200% 300%;
          animation: gradient_rv 20s linear infinite;
        }
       
        #tray > .passive {
          -gtk-icon-effect: dim;
        }
        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }
        #cpu {
          color: #fb958b;
        }

        #memory {
          color: #a1c999;
        }

        #backlight {
          color: #8a909e;
        }

        #custom-launcher {
          color: #7a95c9;
        }

        #custom-power-menu {
          color: #e78284;
        }
      '';
    # --- 7. 动画样式：animation.css ---
    ".config/waybar/animation.css".text =
      # css
      ''
        @keyframes gradient {
          0% {
            background-position: 0% 50%;
          }
          50% {
            background-position: 100% 30%;
          }
          100% {
            background-position: 0% 50%;
          }
        }
        @keyframes gradient_f {
          0% {
            background-position: 0% 200%;
          }
          50% {
            background-position: 200% 0%;
          }
          100% {
            background-position: 400% 200%;
          }
        }
        @keyframes gradient_f_nh {
          0% {
            background-position: 0% 200%;
          }
          100% {
            background-position: 200% 200%;
          }
        }
        @keyframes gradient_rv {
          0% {
            background-position: 200% 200%;
          }
          100% {
            background-position: 0% 200%;
          }
        }
      '';
  };
}
