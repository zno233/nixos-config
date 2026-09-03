{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    let
      # 包装完整的 wpsoffice-cn
      wpsoffice-wrapped = pkgs.symlinkJoin {
        name = "wps-office-wrapped";
        paths = [ pkgs.wpsoffice-cn ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          # 遍历包装 bin 目录下的所有 WPS 组件 (wps, et, wpp, pdf)
          for binary in wps et wpp wpspdf; do
            if [ -e "$out/bin/$binary" ]; then
              # 删除原有的软链接，防止 wrapProgram 冲突
              rm "$out/bin/$binary"
              # 创建包裹环境变量的新启动器
              makeWrapper "${pkgs.wpsoffice-cn}/bin/$binary" "$out/bin/$binary" \
                --set GTK_IM_MODULE fcitx \
                --set QT_IM_MODULE fcitx \
                --set XMODIFIERS "@im=fcitx" \
                --set QT_FONT_DPI 148
            fi
          done

          # 修正 .desktop 文件中的 Exec 路径，使其指向包装后的二进制文件
          rm -rf $out/share/applications
          mkdir -p $out/share/applications
          for desktop in ${pkgs.wpsoffice-cn}/share/applications/*.desktop; do
            substitute "$desktop" "$out/share/applications/$(basename "$desktop")" \
              --replace "${pkgs.wpsoffice-cn}" "$out"
          done
        '';
      };
    in
    {
      home.packages = with pkgs; [
        wpsoffice-wrapped
        # libreoffice
        # onlyoffice-desktopeditors
      ];
    };
}
