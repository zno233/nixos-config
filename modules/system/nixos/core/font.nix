{ pkgs, lib, config, ... }:
{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight"; # 可尝试 "medium" 获得更强清晰度
        # autohint = true;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      # useEmbeddedBitmaps = true;

      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" "wqy-microhei" ];
        serif = [ "lxgw-wenkai" "Noto Serif CJK SC" "Noto Serif" ];
        monospace = [ "Hurmit Nerd Font Mono" "Noto Sans Mono CJK SC" ];
      };
    };

    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      nerd-fonts.hurmit
      lxgw-wenkai
      wqy_zenhei
      wqy_microhei
      sarasa-gothic
      source-han-sans
      source-han-serif
      #joypixels
    ];
  };
}


