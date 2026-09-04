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
    let
      # Noctalia 生成的配色方案路径
      noctaliaGenerated = ./noctalia/generated/stylix-base16.yaml;
    in
    {
      # 1. 基础包
      home.packages = with pkgs; [
        # 光标
        bibata-cursors
      ];

      # 2. 启用并配置 Stylix
      stylix = {
        enable = true;
        autoEnable = false;
        # enableReleaseChecks = false;

        # 【基础壁纸设置】基于一张图片来提取/匹配主题色
        # image = ../../../wallpapers/otherWallpaper/others/anime-girls-cat-girl-white-rose-nature-kawaii-skirt.jpg;

        # 【暗黑主题方案】- 从 Noctalia 生成的配色读取
        base16Scheme = noctaliaGenerated;
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
            name = "monospace"; # 自动走系统里的 [ "Asuka Mono", "Noto Sans Mono" ... ]
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

      # 默认关闭所有 targets，按需开启
      stylix.targets = {
        # # 编辑器
        # vscode.enable = true;
        # zed.enable = true;
        # helix.enable = true;
        # neovim.enable = true;

        # # 终端
        # kitty.enable = true;
        # ghostty.enable = true;
        # starship.enable = true;

        # # 应用
        # spicetify.enable = true;
        yazi.enable = true;
        btop.enable = true;
        fzf.enable = true;
        cava.enable = true;

        zen-browser = {
          enable = true;
          profileNames = [ "default" ];
        };

        # 桌面环境
        gtk.enable = true;
        qt = {
          enable = true;
          standardDialogs = "gtk3";
        };
      };

      # 3. GTK 微调
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
      };
    };
}
