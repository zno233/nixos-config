{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
  inputs.niri.homeModules.niri 
  #./settings.nix 
  #./binds.nix 
  #./rules.nix
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  home = {
    packages = with pkgs; [
      seatd
      jaq
      xwayland-satellite
      wl-clipboard # 核心剪贴板工具
      cliphist     # 剪贴板历史记录
      waybar       # 面板
      swww         # 壁纸
      swaynotificationcenter      # 通知中心
      wf-recorder  # Wayland屏幕录制工具
      hyprpicker  #取色器
      grim        #wayland截图工具
    ];
  };
  xdg.configFile."niri/config.kdl" = {
  source = config.lib.file.mkOutOfStoreSymlink
    "/home/zno/zno-config/modules/home-manager/de/wm/niri/config.kdl";
  # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
  # 而不是先复制到 Store 再链接。
  force = true;
  };
}
