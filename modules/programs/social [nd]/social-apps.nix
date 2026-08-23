{
  flake.modules.homeManager.social-apps =
    { pkgs, ... }:

    let
      # 只包装你的 wechat 包，加输入法变量
      wrappedWechat = pkgs.symlinkJoin {
        name = "wechat";
        paths = [ pkgs.wechat ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/wechat \
            --set QT_IM_MODULE "fcitx" \
            --set XMODIFIERS "@im=fcitx" \
            --set GTK_IM_MODULE "fcitx"
        '';
      };
    in
    {
      home.packages = with pkgs; [
        # global
        telegram-desktop
        element-desktop
        # cn
        wrappedWechat
        qq
      ];
    };
}
