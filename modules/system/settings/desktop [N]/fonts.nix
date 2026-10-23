{
  flake.modules.nixos.fonts =
    {
      pkgs,
      ...
    }:
    {
      fonts = {
        fontconfig = {
          enable = true;
          antialias = true;
          hinting = {
            enable = true;
            style = "slight";
            # autohint = true;
          };
          # subpixel = {
          #   rgba = "rgb";
          #   lcdfilter = "light";
          # };
          # useEmbeddedBitmaps = true;

          defaultFonts = {
            # 西文: 衬线字体（笔画末端有修饰(衬线)的字体，通常用于印刷。）
            # 中文: 宋体（港台称明體）
            serif = [
              "LXGW WenKai Screen"
              "Noto Serif CJK SC"
              "Noto Serif"
            ];

            # 西文: 无衬线字体（指笔画末端没有修饰(衬线)的字体，通常用于屏幕显示）
            # 中文: 黑体
            sansSerif = [
              "HarmonyOS Sans SC"
              # "SF Pro Text"
              "Noto Sans CJK SC"
              "Noto Sans"
            ];

            # 等宽字体
            monospace = [
              "Asuka Mono"
              # "Sarasa Mono SC"
              # "IBM Plex Mono"
              # "Maple mono"
              # "Iosevka Nerd Font"
              "Noto Sans Mono"
            ];

            emoji = [
              "Noto Color Emoji"
            ];
          };

          # 高 DPI下显式关闭stem darkening
          localConf = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
              <!-- 关闭 stem-darkening -->
              <match target="font">
                <edit name="stem-darkening" mode="assign">
                  <bool>false</bool>
                </edit>
              </match>
            </fontconfig>
          '';
        };

        enableDefaultPackages = true;
        fontDir.enable = true;

        packages = with pkgs; [
          # noto fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji

          # asuka fonts
          asuka-fonts

          # 霞鹜文楷
          lxgw-wenkai
          lxgw-wenkai-screen

          # windows字体：来自 nix-packages 的 microsoft scope，按需挑选。
          # 大体等价 Win11 zh-CN 安装的 C:\Windows\Fonts（西文基底 + 简中 FOD）。
          microsoftPackages.windows-fonts-zh-cn-slim

          # 鸿蒙字体：官方 HarmonyOS Sans 简中
          huaweiPackages.harmonyos-sans-sc

          # Maple Mono
          maple-mono.NF

          # Nerd Fonts
          # nerd-fonts.iosevka
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          # nerd-fonts.caskaydia-cove
          # nerd-fonts.symbols-only

          # 其他
          # sarasa-gothic
          ibm-plex
          # joypixels
          # twemoji-color-font # Twitter 风格的 Emoji。
          # fantasque-sans-mono # 手写风格的等宽字体
        ];
      };
    };
}
