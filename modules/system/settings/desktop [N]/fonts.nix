{
  inputs,
  ...
}:
{
  # flake-file.inputs = {
  #   apple-fonts = {
  #     url = "github:Lyndeno/apple-fonts.nix";
  #     inputs.nixpkgs.follows = "nixpkgs";
  #   };
  # };

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
              # "SF Pro Text"
              "Noto Sans CJK SC"
              "Noto Sans"
            ];

            # 等宽字体
            monospace = [
              "Sarasa Mono SC"
              "Maple mono"
              "Hurmit Nerd Font Mono"
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
              <match target="font">
                <edit name="stem-darkening" mode="assign">
                  <bool>false</bool>
                </edit>
              </match>
          '';
        };

        enableDefaultPackages = true;
        fontDir.enable = true;

        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          nerd-fonts.hurmit
          lxgw-wenkai
          lxgw-wenkai-screen
          sarasa-gothic
          #joypixels

          # 苹果字体
          # inputs.apple-fonts.packages.${stdenv.hostPlatform.system}.sf-pro
        ];
      };
    };
}
