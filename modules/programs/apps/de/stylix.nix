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
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        # 字体包（部分供备用或特殊软件调用）
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.caskaydia-cove
        nerd-fonts.symbols-only
        twemoji-color-font
        noto-fonts-color-emoji
        fantasque-sans-mono

        # 图标包
        tela-circle-icon-theme

        # 备用的光标包
        phinger-cursors
        graphite-cursors
        vimix-cursors
      ];

      # 2. 启用并配置 Stylix
      stylix = {
        enable = true;
        autoEnable = true;
        enableReleaseChecks = false;

        # 【基础壁纸设置】Stylix 必须基于一张图片来提取/匹配主题色
        # 请替换为你实际的壁纸路径
        image = ../../../../wallpapers/otherWallpaper/others/anime-girls-cat-girl-white-rose-nature-kawaii-skirt.jpg;

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
            package = pkgs.maple-mono-custom;
            name = "monospace"; # 自动走系统里的 [ "Maple mono", "Sarasa Mono SC" ... ]
          };

          sansSerif = {
            package = pkgs.noto-fonts;
            name = "sansSerif"; # 自动走系统里的 [ "SF Pro Display" "SF Pro Text" "Noto Sans CJK SC" "Noto Sans" ]
          };

          serif = {
            package = pkgs.lxgw-wenkai-screen;
            name = "serif"; # 自动走系统里的 [ "LXGW WenKai Screen", "Noto Serif CJK SC" ... ]
          };

          # 由 Stylix 统一接管的高级字体大小调校
          sizes = {
            applications = 13;
            terminal = 15;
            desktop = 13;
          };
        };
      };

      stylix.targets = {
        # 编辑器
        vscode.enable = false;
        zed.enable = false;
        helix.enable = false;

        # 终端
        kitty.enable = false;
        # fzf.enable = false;

        # 桌面环境
        # niri.enable = false;

        # 应用
        spicetify.enable = false;
        zen-browser.profileNames = [ "default" ];
      };

      # 3. GTK 专属高级微调（如果你想强制保留 Tela-circle-green-dark 图标）
      # Stylix 会自动生成符合 Everforest 颜色的极简 GTK 主题，我们只需要把图标注入进去
      gtk = {
        enable = true;
        gtk4.theme = null;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme.override { color = "green"; };
        };
      };
    };
}
