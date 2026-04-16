{
  self,
  ...
}:
{
  flake.modules.homeManager.niri =
    {
      config,
      pkgs,
      ...
    }:
    let
      niriConfig = "${config.home.homeDirectory}/zno-config/modules/programs/apps/de/wm/niri";
    in
    {
      imports = [
        self.inputs.niri.homeModules.niri
      ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      home = {
        packages = with pkgs; [
          # seatd →改成 system-level services.seatd.enable = true;
          jaq
          xwayland-satellite
          wl-clipboard # 核心剪贴板工具
          cliphist # 剪贴板历史记录
          grim # Wayland 截图工具
          slurp # 屏幕区域选择工具
          satty # 截图标注工具（支持绘图、箭头、文字等）
          hyprpicker # 取色器

          # waybar       # 面板
          # swww         # 壁纸
          # swaynotificationcenter      # 通知中心
          # wf-recorder  # Wayland屏幕录制工具
        ];
      };
      xdg.configFile."niri/config.kdl" = {
        source = ./config.kdl;
      };
      xdg.configFile."niri/patch.kdl" = {
        source = config.lib.file.mkOutOfStoreSymlink "${niriConfig}/patch.kdl";
        force = true;
      };
    };
}
