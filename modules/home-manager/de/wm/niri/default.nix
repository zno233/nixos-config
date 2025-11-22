{
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
  };

  home = {
    packages = with pkgs; [
      seatd
      jaq
      wl-clipboard # 核心剪贴板工具
      cliphist     # 剪贴板历史记录
      waybar       # 面板
      swww         # 壁纸
      swaynotificationcenter      # 通知中心
    ];
  };
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
