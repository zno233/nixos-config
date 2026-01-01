{ config, ... }:
let
  # --- 1. Centralized color definitions ---
  # Base16 Aurora palette (used colors)
  base00 = "09030B"; # Background
  base08 = "BD0952"; # Red - Used for Critical Battery, Power Menu, notification icons
  base0A = "E6C218"; # Yellow - Used for Launcher, Disconnected Network
  base09 = "D08770"; # Orange - NEW: Used for Temperature Icon
  base0B = "a1c999"; # Green - Used for Battery Gradient 1
  base0D = "238DC0"; # Blue - Used for Backlight, Charging/Full Gradient 2
  base0E = "8fbcbb"; # Magenta - Used for Battery normal state, Charging/Full Gradient 1
  
  # Non-Base16/module-specific hardcoded colors
  color_cpu_icon = "fb958b";   # CPU icon color
  color_memory_icon = "a1c999"; # Memory icon color
  color_workspaces_default = "7a95c9"; # Workspaces default button/Launcher/Window border
  color_workspaces_active = "ecd3a0"; # Workspaces active button/Window text
  color_power_menu_icon = "e78284"; # Power Menu icon color
  color_backlight_text = "e5e5e5"; # Backlight text color
  
  # General UI colors
  color_waybar_text = "e5e5e5";    # Waybar module default text color
  color_module_bg = "252733";      # Waybar module background color
  color_window_bg_alpha = "1A1B26"; # Waybar window background (rgba(26, 27, 38, 0.5) equivalent RGB)
  
  # Imported from Base16 but unused in CSS (for tooltip)
  color_tooltip_bg = "100518";      # base01: Lighter Background (Tooltip BG)
  color_tooltip_border = "F8F8F0";  # base07: Brightest Foreground (Tooltip Border)
  
  # Battery gradient colors (Base0F corresponds to Base16 Aurora's Cyan)
  color_battery_grad_1 = "18A121"; # base0B
  color_battery_grad_2 = "7755B8"; # base0F (Cyan, used for Battery Gradient 2)

  trayBackgroundColor = "#${base00}";
  # **Hardcoded main monitor name**
  mainMonitorName = "eDP-1";
  # --- 2. Module configuration (Module Definitions) ---
  moduleConfiguration =
    # jsonc
    ''
      // Modules configuration
      "custom/launcher" : {
        "format" : "<span foreground='#${base0A}'></span>",
        "on-click" : "random-wallpaper",
        "on-click-right" : "rofi -show drun",
        "tooltip" : "true",
        "tooltip-format" : "Random Wallpaper"
      },
      
      "mpris": {
        "format": "<span foreground='#${base0D}'>{icon}</span> {title} - {artist}", 
        "format-paused": "<span foreground='#${base0A}'>{icon}</span> {title} - {artist}", 
        "format-stopped": "<span foreground='#${base08}'>{icon}</span>",
        "interval": 0,
        "tooltip": true,
        "artist-len": 15,
        "title-len": 25,
    
        "format-icons": {
        "Playing": "",
        "Paused": "",
        "Stopped": "",
        "default": ""   
      },
    
      "on-click": "playerctl play-pause",
      "on-scroll-up": "playerctl next",
      "on-scroll-down": "playerctl previous"
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
      
      "temperature": {
        "hwmon-path": "/sys/class/hwmon/hwmon4/temp1_input",
        "critical-threshold": 80,
        "format": "<span foreground='#${base09}'> </span>{temperatureC}°C",
        "format-alt": "<span foreground='#${base09}'> </span>{temperatureF}°F",
        "tooltip-format": "Temperature: {temperatureC}°C",
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
      
      "cpu": {
        "format": "<span foreground='#${color_cpu_icon}'> </span> {usage}%",
        "format-alt": "<span foreground='#${color_cpu_icon}'> </span> {avg_frequency} GHz",
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
          }
      },

      "hyprland/window": {
        "format": "{}",
        "separate-outputs": true,
        "max-length": 25,
        "icon": true,
        "icon-size": 18
      },
      "memory": {
        "format": "<span foreground='#${color_memory_icon}'>󰟜 </span>{}%",
        "format-alt": "<span foreground='#${color_memory_icon}'>󰟜 </span>{used} GiB",
        "interval": 2,
        "on-click-right": "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'"
      },
      "backlight": {
        "device": "intel_backlight",
        "on-scroll-up": "light -A 1",
        "on-scroll-down": "light -U 1",
        "format": "<span foreground='#${base0D}'>{icon}</span>",
        "format-icons": ["󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨"], 
        "tooltip-format":"{percent}%" 
      },
      "tray": {
        "icon-size": 16,
        "spacing": 10
      },
      "clock": {
        "format": "<span foreground='#ecd3a0'> </span> {:%a %d %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "on-click": "kitty --class=clock,clock --title=clock -o remember_window_size=no -o initial_window_width=600 -o initial_window_height=200 -e tty-clock -s -c -C 5"
      },
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "<span foreground='#${base0E}'>{icon}</span>",
        "format-warning": "<span foreground='#${base0E}'>{icon}</span>",
        "format-critical": "<span foreground='#${base08}'>{icon}</span>",
        "format-charging": "<span foreground='#${base0E}'></span>",
        "format-plugged": "<span foreground='#${base0E}'></span>",
        "format-alt": "<span foreground='#${base0E}'>{icon}</span>",
        "format-full": "<span foreground='#${base0E}'></span>",
        "format-icons": [
          "", "", "", "", ""
        ],
        "tooltip-format": "{capacity}%",
        "interval": 5
      },
      "network": {
        "format-wifi": "<span foreground='#5E81AC'>󰖩</span>",
        "format-ethernet": "<span foreground='#${base0A}'>󰤭</span>",
        "format-linked": "󱚵",
        "format-disconnected": "<span foreground='#fb958b'></span>", 
        "tooltip-format-wifi": "{essid} \nSignal Strenght: {signalStrength}%",
        "tooltip-format-ethernet": "Ethernet: {ipaddr}\nInterface: {ifname}",
        "tooltip-format-disconnected": "Network Disconnected"
        //"on-click": "kitty --class nmtui,nmtui --title=nmtui -o remember_window_size=no -o initial_window_width=400 -o initial_window_height=400 -e doas nmtui"
      },
      "pulseaudio": {
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-right" : "pavucontrol",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-",
        "format": "<span foreground='#81A1C1'>{icon}</span>",
        "format-muted": "<span foreground='#fb958b'></span>",
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
        },
        "tooltip-format":"{volume}%",
        "tooltip-format-muted": "Volume: Muted"
      },
      "group/meters": {
        "orientation": "inherit",
        "spacing": 10,
        "modules": [
          "battery",
          "network",
          "pulseaudio",
          "backlight",
          "custom/notification"
        ]
      }
    '';
in
{
  programs.waybar = {
    enable = true;
  };
  home.file = {
    # --- 3. Config file: config.jsonc (includes group module config) ---
    ".config/waybar/config.jsonc".text =
      # json
      ''
        [
          {
            "position": "top",
            "layer": "top",
            "output": "${mainMonitorName}",
            "margin-top": 5,
            "margin-bottom": 5,
            "margin-left": 5,
            "margin-right": 5,

            "modules-left": [
              "custom/launcher",
              "hyprland/workspaces",       
              "cpu",
              "memory",
              "temperature"
            ],
            "modules-center": [
              "hyprland/window"
            ],
            "modules-right": [
              "tray",
              "group/meters",
              "clock",
              "custom/power-menu"
            ],
            ${moduleConfiguration}
          }
        ]
      '';
    # --- 4. Color definitions: colors.css ---
    ".config/waybar/colors.css".text =
      # css
      ''
        @define-color base00 #${base00};
        @define-color base01 #${color_tooltip_bg}; /* Tooltip BG */
        @define-color base07 #${color_tooltip_border}; /* Tooltip Border */
        @define-color base0B #${base0B}; /* Battery Grad 1 */
        @define-color base0D #${base0D}; /* Charging Grad 2 */
        @define-color base0E #${base0E}; /* Charging Grad 1 */
        @define-color base0F #${color_battery_grad_2}; /* Battery Grad 2 (Cyan) */
        @define-color base09 #${base09};
        
        @define-color color_waybar_text #${color_waybar_text};
        @define-color color_module_bg #${color_module_bg};
        @define-color color_workspaces_default #${color_workspaces_default};
        @define-color color_workspaces_active #${color_workspaces_active};
        @define-color color_cpu_icon #${color_cpu_icon};
        @define-color color_memory_icon #${color_memory_icon};
        @define-color color_power_menu_icon #${color_power_menu_icon};
        @define-color color_backlight_text #${color_backlight_text};
        @define-color color_window_bg_alpha #${color_window_bg_alpha};
      '';
    # --- 5. Tray styles: tray.css (using base00) ---
    ".config/waybar/tray.css".text =
      # css
      ''
        #tray {
          background: alpha(@base00, 0.7);
        }
      '';
     # --- 6. Main styles: style.css (includes visual styles for all modules) ---
    ".config/waybar/style.css".text =
      # css
      ''
        @import "animation.css";
        @import "colors.css";
        @import "tray.css";
        * {
          /* all: unset; */
          font-size: 15px;
          font-family: "Maple Mono", "lxgw-wenkai";
          min-height: 0;
        }
        window#waybar {
          background-color: rgba(26, 27, 38, 0.5); /* target color */
          color: #ffffff;
          transition-property: all;
          transition-duration: 0.5s;
          border-radius: 10px;
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
        /* --------------------------------- General module styles (dark background, rounded corners, shadows) --------------------------------- */
        #clock,
        #memory,
        #tray,
        #meters,
        #cpu,
        #temperature,
        #mpris,
        #custom-launcher,
        #custom-power-menu
        {
          color: @color_waybar_text;
          border-radius: 8px;
          padding: 3px 10px;
          background-color: @color_module_bg; 
          margin-left: 4px;
          margin-right: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          font-size: 16px;    
          text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.377);
        }
        
        /* --------------------------------- Unified styles within the group (key rules) --------------------------------- */
        /* Ensure sub-modules in the group (battery, network, pulseaudio, backlight) have no independent background or animation */
        #meters > * {
          background-color: transparent;
          box-shadow: none;
          margin: 0;
          padding: 0 3px;
          border-radius: 0;
          animation: none;
          background: none;
          border: none;
          font-size: 16px;
        }

        #meters > * label {
          font-size: 16px;
          min-width: 25px;
          padding: 0;
          margin: 0;
          
        }
     
        /* --------------------------------- Hyprland/workspaces styles (#workspaces) --------------------------------- */
        #workspaces {
          background: transparent;
          box-shadow: none;
          border-radius: 0px;
          margin-top: 4px;
          margin-bottom: 4px;
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
          color: @color_workspaces_default;
        }
        #workspaces button.active {
          font-size: 1px;
          border-radius: 20px;
          min-width: 30px;
          background-size: 400% 400%;
          color: @color_workspaces_active;
        }
        /* --------------------------------- Hyprland/window styles (#window) --------------------------------- */
        #window {
          background: transparent;
          box-shadow: none;
          
          border: 1px solid @color_workspaces_default; /* Keep line border */
          border-radius: 10px;
          
          padding: 1px 10px;
          margin-top: 4px;
          margin-bottom: 4px;
          margin-left: 5px;
          margin-right: 5px;
          
          color: @color_workspaces_active;
          
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
        
        #tray > .passive {
          -gtk-icon-effect: dim;
        }
        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }
        #cpu {
          color: @color_cpu_icon;
        }

        #memory {
          color: @color_memory_icon;
        }
        
        #temperature {
          color: @base09; /* 确保模块主文本是通用白色 */
        }

        #backlight {
          color: @color_backlight_text;
        }

        #custom-launcher {
          color: @color_workspaces_default;
        }

        #custom-power-menu {
          color: @color_power_menu_icon;
        }
        #meters {
          padding: 3px 10px;
      }
      '';
    # --- 7. Animation styles: animation.css ---
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
