{
  self,
  ...
}:
{
  flake.modules.homeManager.stylix =
    {
      pkgs,
      lib,
      ...
    }:
    {
      # 1. 依然保留基础的字体配置和非 Stylix 接管的独立工具包
      home.packages = with pkgs; [
        # 光标
        bibata-cursors
      ];

      # 2. 启用并配置 Stylix
      stylix = {
        enable = true;
        autoEnable = true;
        # enableReleaseChecks = false;

        # 【基础壁纸设置】Stylix 必须基于一张图片来提取/匹配主题色
        # 替换为实际的壁纸路径
        image = ../../../wallpapers/otherWallpaper/others/anime-girls-cat-girl-white-rose-nature-kawaii-skirt.jpg;

        # 【现代暗黑主题方案】
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
        polarity = "dark";

        # 【全局光标同步】
        cursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 22;
        };

        # 【字体防冲突优化】
        # 名字全部填标准的 Fontconfig 别名，确保 100% 触发你 NixOS 系统级配置的中西文回落链。
        # 这里的 package 属性仅作为 Nix 语法编译的“占位符”，不会与系统发生冲突。
        fonts = {
          monospace = {
            package = pkgs.maple-mono.NF;
            name = "monospace"; # 自动走系统里的 [ "Sarasa Mono SC", "Iosevka Nerd Font" ... ]
          };

          sansSerif = {
            package = pkgs.noto-fonts;
            name = "sans-serif"; # 自动走系统里的 [ "HarmonyOS Sans SC" "Noto Sans CJK SC" ]
          };

          serif = {
            package = pkgs.lxgw-wenkai-screen;
            name = "serif"; # 自动走系统里的 [ "LXGW WenKai Screen", "Noto Serif CJK SC" ... ]
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "emoji"; # 自动走系统里的 [ "Noto Color Emoji" ]
          };

          # 由 Stylix 统一接管的高级字体大小调校
          sizes = {
            applications = 12;
            terminal = 15;
            desktop = 12;
          };
        };
      };

      stylix.targets = {
        # 编辑器
        vscode.enable = false;
        zed.enable = false;
        helix.enable = false;
        neovim.enable = false;

        # 终端
        kitty.enable = false;
        # fzf.enable = false;

        # shell prompt：使用自带的 Gruvbox Rainbow 预设（自定义 color_* 调色板），不交给 Stylix 接管
        starship.enable = false;

        # 桌面环境
        # niri.enable = false;
        qt = {
          # xdgdesktopportal：需要系统已配置 xdg-desktop-portal-gtk 或 -kde
          # 如果弹出的文件选择对话框样式异常，改回 "gtk3"
          standardDialogs = "xdgdesktopportal";
        };

        # 应用
        spicetify.enable = false;
        zen-browser.profileNames = [ "default" ];
      };

      # 3. GTK 专属高级微调
      # Stylix 会自动生成符合颜色主题的极简 GTK 主题，我们只需要把图标注入进去
      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme.override { color = "green"; };
        };
      };

      qt.kvantum = {
        enable = true;
        # settings = {
        #   General = {
        #     theme = "Base16Kvantum";

        #     # === 容器圆角 ===
        #     roundness = 10;
        #     frameRoundness = 10;
        #     groupBoxRoundness = 10;
        #     dockRoundness = 10;
        #     viewRoundness = 8;

        #     # === 控件圆角 ===
        #     buttonRoundness = 6;
        #     comboBoxRoundness = 6;
        #     tabRoundness = 6;
        #     popupRoundness = 8;
        #     menuRoundness = 8;

        #     # === 细节圆角 ===
        #     scrollBarRoundness = 6;
        #     tooltipRoundness = 6;
        #     menuItemRoundness = 4;

        #     # === 阴影 ===
        #     shadowSize = 24;
        #     shadowIntensity = 0.25;
        #     shadowOffset = 0;

        #     # === 尺寸与间距 ===
        #     layoutMargin = 4;
        #     layoutSpacing = 3;
        #     groupBoxMargin = 6;
        #     frameMargin = 6;
        #     viewMargin = 4;
        #     viewItemMargin = 4;
        #     toolbarMargin = 4;
        #     toolbarSpacing = 4;
        #     toolButtonMargin = 3;

        #     menuItemHeight = 24;
        #     menuVerticalMargin = 4;
        #     menuHorizontalMargin = 6;
        #     popupMargin = 6;
        #     scrollableMenu = true;

        #     scrollBarWidth = 12;
        #     scrollBarPadding = 3;
        #     splitterWidth = 3;

        #     # === 工具栏与图标 ===
        #     toolButtonStyle = "FollowStyle";
        #     toolbarIconSize = 18;
        #     smallIconSize = 14;
        #     largeIconSize = 18;
        #     noButtonGradient = true;

        #     # === 交互 ===
        #     animationDuration = 150;
        #     menuDelay = 100;
        #     backgroundTransparency = 0;
        #     windowDrag = "always";
        #     tabOverlap = 1;
        #   };
        # };
      };
    };
}
