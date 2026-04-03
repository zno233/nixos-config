{
  config,
  inputs,
  pkgs,
  ...
}:
let
  niriConfig = "${config.home.homeDirectory}/zno-config/home/common/de/wm/niri/config.kdl";
in
{
  imports = [
    inputs.niri.homeModules.niri
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

      # waybar       # 面板
      # swww         # 壁纸
      # swaynotificationcenter      # 通知中心
      # wf-recorder  # Wayland屏幕录制工具
      # hyprpicker   # 取色器
      # grim         # wayland截图工具
    ];
  };
  xdg.configFile."niri/config.kdl" = {
    source = config.lib.file.mkOutOfStoreSymlink "${niriConfig}";
    force = true;
  };
}
