{ config, ... }:
let
  # --- 1. 强制定义目标格式中的 Base16 变量  ---
  base00 = "09030B"; # Background
  base01 = "100518"; # Lighter Background
  base04 = "78598D"; # Lighter Foreground
  base05 = "A6A2A4"; # Foreground
  base06 = "E8DCD1"; # Brighter Foreground
  base07 = "F8F8F0"; # Brightest Foreground
  base08 = "BD0952"; # Red
  base0A = "E6C218"; # Yellow
  base0B = "18A121"; # Green
  base0D = "238DC0"; # Blue
  base0E = "78598D"; # Magenta
  base0F = "7755B8"; # Cyan
  
  trayBackgroundColor = "#${base00}";
  # **硬编码主显示器名称** (从原始配置中获取)
  mainMonitorName = "eDP-1"; 
  
  # --- 2. 模块配置 (Module Definitions) ---
  # 完全照抄原始 JSON 配置，移除顶层大括号
  moduleConfiguration =
    # jsonc
    ''
      "height": 40, // Waybar height (to be removed for auto height)
      "layer": "top", // Waybar at top layer
      "modules-left": ["custom/launcher", "cpu", "memory", "wlr/workspaces", "custom/weather"],
      "modules-right": ["tray", "network", "pulseaudio",  "backlight", "battery", "custom/lock", "clock", "custom/power-menu"],
      "wlr/workspaces": {
        "format": "{icon}",
        "on-click": "activate",
        "format-icons": {
          "active": " 󰮯",
          "default": "",
        }
      },
      "hyprland/window": {
          "format": "{}"
      },
      "tray": {
          "spacing": 10
      },
      "clock": {
          "format": "{:%H:%M}",
          "format-alt": "{:%b %d %Y}",
          "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
      },

      "cpu": {
        "interval": 10,
        "format": " {}%",
        "max-length": 10,
        "on-click": "",
      },
      "memory": {
          "interval": 30,
          "format": " {}%",
          "format-alt":" {used:0.1f}GB",
          "max-length": 10,
      },
      "backlight": {
          "device": "eDP-1",
          "format": "{icon}",
          "tooltip-format": "{percent}",
          "format-icons": ["󱩎 ", "󱩏 ", "󱩐 ", "󱩑 ", "󱩒 ", "󱩓 ", "󱩔 ", "󱩕 ", "󱩖 ", "󰛨 "],

      },
      "network": {
          /* "format-wifi": "直", */
          "format-wifi": "{icon}",
          "format-ethernet": " ",
          "format-disconnected": "睊",
          "tooltip-format": "{essid}",
          "on-click": "~/.config/waybar/scripts/network/rofi-network-manager.sh",
          "format-icons": ["󰤯","󰤟","󰤢","󰤥","󰤨"],
      },

      "pulseaudio": {
          "format": "{icon}",
          "format-muted": "婢",
          "format-icons": {
              "default": ["", "", "墳"]
          },
          "on-click": "pavucontrol &"
      },

      "battery": {
        "bat": "BAT0",
        "adapter": "ADP0",
        "interval": 60,
        "states": {
            "warning": 30,
            "critical": 15
        },
        "max-length": 20,
        "format": "{icon} ",
        "format-warning": "{icon}",
        "format-critical": "{icon}",
        "format-charging": "<span font-family='Font Awesome 6 Free'></span>",
        "format-plugged": "ﮣ", 

        "format-alt": "{icon} {time}",
        "format-full": "ﮣ", 
        "format-icons": ["󱊡", "󱊢", "󱊣"]
      },
      "custom/weather": {
        "exec": "python3 ~/.config/waybar/scripts/weather.py",
        "restart-interval": 300,
        "return-type": "json",
      },   
     "custom/lock": {
         "tooltip" : false,
         "on-click": "swaylock",
         "format" : "",
      },
     "custom/spotify": {
          "exec": "python3 ~/.config/waybar/scripts/mediaplayer.py --player spotify",
          "format": " {}",
          "return-type": "json",
          "on-click": "playerctl play-pause",
          "on-double-click-right": "playerctl next",
          "on-scroll-down": "playerctl previous",
      },
      "custom/power-menu": {
          "format": " ⏻ ",
          "on-click": "bash ~/.config/waybar/scripts/power-menu/powermenu.sh &",
      }, 
      "custom/launcher": {
          "format": "",
          "on-click": "rofi -show drun &",
      }
    '';
in
{
  programs.waybar = {
    enable = true;
  };
  home.file = {
    # --- 3. 配置文件：config.jsonc ---
    # 使用原始配置中的 modules-left 和 modules-right 列表
    ".config/waybar/config.jsonc".text =
      # json
      ''
        [
          {
            "position": "top",
            "layer": "top",
            "output": "${mainMonitorName}",
            "modules-left": ["custom/launcher", "cpu", "memory", "wlr/workspaces", "custom/weather"],
            "modules-center": ["hyprland/window", "custom/spotify"],
            "modules-right": ["tray", "network", "pulseaudio",  "backlight", "battery", "custom/lock", "clock", "custom/power-menu"],
            ${moduleConfiguration}
          }
        ]
      '';
    # --- 4. 颜色定义：colors.css ---
    # 强制定义目标格式中的 Base16 颜色变量，避免导入错误
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
    # --- 5. 托盘样式：tray.css (保持最简单的结构) ---
    ".config/waybar/tray.css".text =
      # css
      ''
        #tray {
          /* 保持 tray.css 结构，使用 Base00 作为背景（或使用原始颜色，这里使用默认的 Base00） */
          background: alpha(@base00, 0.7);
        }
      '';
    # --- 6. 主样式：style.css (包含所有模块的视觉样式) ---
    # 完全照抄原始 CSS 样式
    ".config/waybar/style.css".text =
      # css
      ''
        @import "animation.css";
        @import "colors.css";
        @import "tray.css";
        * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Material Design Icons, JetBrainsMono Nerd Font, Iosevka Nerd Font;
          font-size: 19px;
        }

        window#waybar {
          background-color: rgba(26, 27, 38, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        window#waybar.hidden {
          opacity: 0.1;
        }

        #window {
          color: #64727d;
        }

        #clock,
        #cpu,
        #memory,
        #custom-media,
        #tray,
        #mode,
        #custom-lock,
        #wlr-workspaces, /* wlr/workspaces 模块对应的 CSS ID */
        #idle_inhibitor,
        #custom-power-menu,
        #custom-launcher,
        #custom-spotify,
        #custom-weather,
        #custom-weather.severe,
        #custom-weather.sunnyDay,
        #custom-weather.clearNight,
        #custom-weather.cloudyFoggyDay,
        #custom-weather.cloudyFoggyNight,
        #custom-weather.rainyDay,
        #custom-weather.rainyNight,
        #custom-weather.showyIcyDay,
        #custom-weather.snowyIcyNight,
        #custom-weather.default {
          color: #e5e5e5;
          border-radius: 6px;
          padding: 2px 10px;
          background-color: #252733;
          border-radius: 8px;
          font-size: 18.5px;

          margin-left: 4px;
          margin-right: 4px;

          margin-top: 8.5px;
          margin-bottom: 8.5px;
        }

        #cpu {
          color: #fb958b;
        }

        #memory {
          color: #a1c999;
        }

        #wlr-workspaces button {
          color: #7a95c9;
          box-shadow: inset 0 -3px transparent;

          padding-right: 3px;
          padding-left: 4px;

          margin-left: 0.1em;
          margin-right: 0em;
          transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
        }

        #wlr-workspaces button.active {
          color: #ecd3a0;
          padding-left: 1px;
          padding-right: 12px;
          margin-left: 0em;
          margin-right: 0em;
          transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #wlr-workspaces {
          margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #wlr-workspaces {
          margin-right: 0;
        }

        #custom-launcher {
          margin-left: 12px;

          padding-right: 18px;
          padding-left: 14px;

          font-size: 22px;

          color: #7a95c9;

          margin-top: 8.5px;
          margin-bottom: 8.5px;
        }

        #backlight,
        #battery,
        #pulseaudio,
        #network {
          background-color: #252733;
          padding: 0em 2em;

          font-size: 20px;

          padding-left: 7.5px;
          padding-right: 7.5px;

          padding-top: 3px;
          padding-bottom: 3px;

          margin-top: 7px;
          margin-bottom: 7px;

          font-size: 20px;
        }

        #pulseaudio {
          color: #81A1C1;
          padding-left: 9px;
          font-size: 22px;
        }

        #pulseaudio.muted {
          color: #fb958b;
          padding-left: 9px;
          font-size: 22px;
        }

        #backlight {
          color: #8a909e;
          padding-right: 5px;
          padding-left: 8px;
          font-size: 21.2px;
        }

        #network {
          padding-left: 0.2em;
          color: #5E81AC;
          border-radius: 8px 0px 0px 8px;
          padding-left: 12px;
          padding-right: 14px;
          font-size: 20px;
        }

        #network.disconnected {
          color: #fb958b;
        }

        #battery {
          color: #8fbcbb;
          border-radius: 0px 8px 8px 0px;
          padding-right: 2px;
          font-size: 22px;
        }

        #battery.critical,
        #battery.warning,
        #battery.full,
        #battery.plugged {
          color: #8fbcbb;
          padding-left: 6px;
          padding-right: 12px;
          font-size: 22px;
        }

        #battery.charging { 
          font-size: 18px;
          padding-right: 13px;
          padding-left: 4px;
        }

        #battery.full,
        #battery.plugged {
          font-size: 22.5px;
          padding-right: 10px;
        }

        @keyframes blink {
          to {
            background-color: rgba(30, 34, 42, 0.5);
            color: #abb2bf;
          }
        }

        #battery.warning {
          color: #ecd3a0;
        }

        #battery.critical:not(.charging) {
          color: #fb958b;
        }

        #custom-lock {
          color: #ecd3a0;
          padding: 0 15px 0 15px;
          margin-left: 7px;
          margin-top: 7px;
          margin-bottom: 7px;
        }

        #clock {
          color: #8a909e;
          font-family: Iosevka Nerd Font;
          font-weight: bold;
          margin-top: 7px;
          margin-bottom: 7px;
        }

        #custom-power-menu {
          color: #e78284;
          margin-right: 12px;
          border-radius: 8px;
          padding: 0 6px 0 6.8px;
          margin-top: 7px;
          margin-bottom: 7px;
        }

        tooltip {
          font-family: Iosevka Nerd Font;
          border-radius: 15px;
          padding: 15px;
          background-color: #1f232b;
        }

        tooltip label {
          font-family: Iosevka Nerd Font;
          padding: 5px;
        }

        label:focus {
          background-color: #1f232b;
        }

        #tray {
          margin-right: 8px;
          margin-top: 7px;
          margin-bottom: 7px;
          font-size: 30px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
        }

        #idle_inhibitor {
          background-color: #242933;
        }

        #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
        }

        #custom-spotify {
          color: #abb2bf;
        }

        #custom-weather {
          font-family: Iosevka Nerd Font;
          font-size: 19px;
          color: #8a909e;
        }

        #custom-weather.severe {
          color: #eb937d;
        }

        #custom-weather.sunnyDay {
          color: #c2ca76;
        }

        #custom-weather.clearNight {
          color: #cad3f5;
        }

        #custom-weather.cloudyFoggyDay,
        #custom-weather.cloudyFoggyNight {
          color: #c2ddda;
        }

        #custom-weather.rainyDay,
        #custom-weather.rainyNight {
          color: #5aaca5;
        }

        #custom-weather.showyIcyDay,
        #custom-weather.snowyIcyNight {
          color: #d6e7e5;
        }

        #custom-weather.default {
          color: #dbd9d8;
        }
      '';
    # --- 7. 动画样式：animation.css ---
    # 原始配置中没有 animation.css，但目标格式要求引入，此处保留空内容
    ".config/waybar/animation.css".text =
      # css
      ''
        /* Keeping animation.css empty as per the original source */
      '';
  };
}
