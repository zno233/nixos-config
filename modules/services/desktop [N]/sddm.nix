{
  flake.modules.nixos.sddm =
    {
      pkgs,
      ...
    }:
    let
      sddm-astronaut =
        (pkgs.sddm-astronaut.override {
          embeddedTheme = "hyprland_kath";
          themeConfig = {
            # 1. 修正分辨率，让主题按实际屏幕像素渲染
            ScreenWidth = "2560";
            ScreenHeight = "1680";

            # 2. 调大字体，适配 2.5K 高分屏
            FontSize = "16";
            HeaderFontSize = "28";

            # 3. 调大输入框（登录框）的宽度，防止 1.75 倍缩放后挤在一起
            LoginWidth = "500";

            # 4. 确保布局居中或居左时有足够的边距
            ThemePadding = "30";
          };
        }).overrideAttrs
          (oldAttrs: {
            # Optional: Inject custom background image
            # installPhase = oldAttrs.installPhase + ''
            #   chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
            #   cp ${./relative/path/to/your-custom-background.png} \
            #     $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/your-custom-background.png
            # '';
          });
    in
    {
      environment.systemPackages = [
        sddm-astronaut
      ];

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia # Required for video backgrounds/audio
        ];
        theme = "sddm-astronaut-theme";
        # settings = {
        #   Theme = {
        #     CursorTheme = "Bibata-Modern-Ice";
        #     CursorSize = 40;
        #   };
        # };
      };

      # 添加niri会话
      services.displayManager.sessionPackages = [ pkgs.niri ];

      # unlock GPG keyring on login
      security.pam.services.sddm.enableGnomeKeyring = true;
    };
}
