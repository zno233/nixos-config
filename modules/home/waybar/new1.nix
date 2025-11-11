{ config, ... }: 

let
  # --- 1. 硬编码 Base16 Aurora 调色板颜色 ---
  base00 = "09030B"; # Background
  base01 = "100518"; # Lighter Background (Tooltip BG)
  base04 = "78598D"; # Lighter Foreground (Empty Workspaces)
  base05 = "A6A2A4"; # Foreground (Default Text)
  base06 = "E8DCD1"; # Brighter Foreground (Network Icon)
  base07 = "F8F8F0"; # Brightest Foreground (Tooltip Border, Inactive Workspaces)
  base08 = "BD0952"; # Red (Critical Battery)
  base0A = "E6C218"; # Yellow (Volume Icon)
  base0B = "18A121"; # Green (Battery Gradient 1)
  base0D = "238DC0"; # Blue (Backlight, Charging/Full Gradient 2)
  base0E = "78598D"; # Magenta (Memory, Clock, Active Workspaces, Charging/Full Gradient 1)
  base0F = "7755B8"; # Cyan (Battery Gradient 2)

  # 托盘背景颜色：使用 base00
  trayBackgroundColor = "#${base00}";

  # **硬编码主显示器名称**：
  # 这是一个常见的主显示器名称。如果您知道您的显示器名称，请替换它。
  mainMonitorName = "eDP-1"; 

  moduleConfiguration =
    # jsonc
    ''
      // Modules configuration
      "niri/workspaces": {
        "format": "{icon}",
          "format-icons": {
          "default": ""
        },
      },
      "niri/window": {
        "format": "{}",
        "separate-outputs": true,
        "icon": true,
        "icon-size": 18
      },
      "memory": {
        "interval": 30,
        "format": "<span foreground='#${base0E}'>  </span>  {used:0.1f}G/{total:0.1f}G",
        "on-click": "kitty --class=htop,htop -e htop"
      },
      "backlight": {
        "device": "intel_backlight",
        "on-scroll-up": "light -A 1",
        "on-scroll-down": "light -U 1",
        "format": "<span size='13000' foreground='#${base0D}'>{icon} </span>  {percent}%",
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
        "format": "<span foreground='#${base0E}'>  </span>  {:%a %d %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "on-click": "kitty --class=clock,clock --title=clock -o remember_window_size=no -o initial_window_width=600 -o initial_window_height=200 -e tty-clock -s -c -C 5"
      },
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15,
        },
        "format": "<span size='13000' foreground='#${base0E}'>{icon}  </span>{capacity}%",
        "format-warning": "<span size='13000' foreground='#${base0E}'>{icon}  </span>{capacity}%",
        "format-critical": "<span size='13000' foreground='#${base08}'>{icon}  </span>{capacity}%",
        "format-charging": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
        "format-plugged": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
        "format-alt": "<span size='13000' foreground='#${base0E}'>{icon} </span>{time}",
        "format-full": "<span size='13000' foreground='#${base0E}'>  </span>{capacity}%",
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
      "network": {
        "format-wifi": "<span size='13000' foreground='#${base06}'>󰖩  </span>{essid}",
        "format-ethernet": "<span size='13000' foreground='#${base06}'>󰤭</span> Disconnected",
        "format-linked": "{ifname} (No IP) 󱚵",
        "format-disconnected": "<span size='13000' foreground='#${base06}'> </span>Disconnected",
        "tooltip-format-wifi": "Signal Strenght: {signalStrength}%",
        "on-click": "kitty --class nmtui,nmtui --title=nmtui -o remember_window_size=no -o initial_window_width=400 -o initial_window_height=400 -e doas nmtui"
      },
      "pulseaudio": {
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-",
        "format": "<span size='13000' foreground='#${base0A}'>{icon}  </span>{volume}%",
        "format-muted": "<span size='13000' foreground='#${base0A}'>  </span>Muted",
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
    systemd = {
      enable = true;
      target = config.wayland.systemd.target;
    };
  };

  home.file = {
    # --- 2. 配置文件：config.jsonc (仅包含主显示器) ---
    ".config/waybar/config.jsonc".text =
      # json
      ''
        [
          {
            "position": "top",
            "layer": "top",
            "output": "${mainMonitorName}",
            "modules-left": [
              "niri/workspaces",
              "tray",
              "niri/window"
            ],
            "modules-center": [
              "clock",
              "memory"
            ],
            "modules-right": [
              "network",
              "pulseaudio",
              "backlight",
              "battery"
            ],
            ${moduleConfiguration}
          }
        ]
      '';

    # --- 3. 颜色定义：colors.css ---
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

    # --- 4. 托盘样式：tray.css ---
    ".config/waybar/tray.css".text =
      # css
      ''
        #tray {
          background: shade(alpha(${trayBackgroundColor}, 0.9), 1);
        }
      '';

    # --- 5. 主样式：style.css ---
    ".config/waybar/style.css".text =
      # css
      ''
        @import "animation.css";
        @import "colors.css";
        @import "tray.css";

        * {
          /* all: unset; */
          font-size: 14px;
          /* font-family: "Comic Mono Nerd Font"; */
          font-family: "Hug Me Tight", "Xiaolai SC";
          min-height: 0;
        }

        window#waybar {
          /* border-radius: 15px; */
          /* color: @base04; */
          background: transparent;
        }

        tooltip {
          background: @base01;
          border-radius: 5px;
          border-width: 2px;
          border-style: solid;
          border-color: @base07;
        }

        #network,
        #clock,
        #battery,
        #pulseaudio,
        #workspaces,
        #backlight,
        #memory,
        #tray,
        #window {
          padding: 4px 10px;
          background: shade(alpha(@base00, 0.9), 1);
          text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
          color: @base05;
          margin-top: 10px;
          margin-bottom: 5px;
          margin-left: 5px;
          margin-right: 5px;
          box-shadow: 1px 2px 2px #101010;
          border-radius: 10px;
        }

        #workspaces {
          margin-left: 15px;
          font-size: 0px;
          padding: 6px 3px;
          border-radius: 20px;
        }

        #workspaces button {
          font-size: 0px;
          background-color: @base07;
          padding: 0px 1px;
          margin: 0px 4px;
          border-radius: 20px;
          transition: all 0.25s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }

        #workspaces button.active {
          font-size: 1px;
          background-color: @base0E;
          border-radius: 20px;
          min-width: 30px;
          background-size: 400% 400%;
        }

        #workspaces button.empty {
          font-size: 1px;
          background-color: @base04;
        }

        #window {
          color: @base00;
          background: radial-gradient(circle, @base05 0%, @base07 100%);
          background-size: 400% 400%;
          animation: gradient_f 40s ease-in-out infinite;
          transition: all 0.3s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }

        window#waybar.empty #window {
          background: none;
          background-color: transparent;
          box-shadow: none;
        }

        #battery {
          margin-right: 15px;
          background: @base0F;
          /* 保持渐变颜色不变 */
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

        #battery.charging,
        #battery.plugged {
          /* 保持充电渐变颜色不变 */
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

        #battery.full {
          /* 保持满电渐变颜色不变 */
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
          animation: gradient_rv 20s linear infinite;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }
      '';

    # --- 6. 动画样式：animation.css ---
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
