{
  flake.modules.homeManager.kitty =
    {
      lib,
      ...
    }:
    {
      programs.kitty = {
        enable = true;

        themeFile = "gruvbox-dark-hard";

        font = {
          name = "Asuka Mono";
          size = 15;
        };

        extraConfig = ''
          cursor_trail 3
          cursor_trail_decay 0.1 0.4
          cursor_trail_start_threshold 2
          cursor_trail_color none

          font_features Asuka Mono +dlig
        '';

        settings = {
          # https://github.com/kovidgoyal/kitty/issues/10102
          auto_reload_config = -1;

          confirm_os_window_close = 0;
          background_opacity = lib.mkForce "0.8";
          scrollback_lines = 10000;
          enable_audio_bell = false;
          mouse_hide_wait = 60;
          window_padding_width = "2";

          ## Tabs
          tab_bar_edge = "bottom";
          tab_bar_min_tabs = 1;
          tab_bar_margin_height = "4 0";
          tab_bar_style = "custom"; # 使用 tab_bar.py
          tab_bar_background = "none"; # 让空白处透明/跟随背景
          # tab_title_template = "{index} > {title}";
          # tab_title_max_length = 20;
          # active_tab_font_style = "normal";
          # inactive_tab_font_style = "normal";
          # active_tab_foreground = "#FBF1C7";
          # active_tab_background = "#7C6F64";
          # inactive_tab_foreground = "#FBF1C7";
          # inactive_tab_background = "#3C3836";
        };

        keybindings = {
          ## Tabs
          "alt+1" = "goto_tab 1";
          "alt+2" = "goto_tab 2";
          "alt+3" = "goto_tab 3";
          "alt+4" = "goto_tab 4";

          ## Unbind
          "ctrl+shift+left" = "no_op";
          "ctrl+shift+right" = "no_op";
        };
      };

      xdg.configFile."kitty/tab_bar.py".source = ./tab_bar.py;
    };
}
