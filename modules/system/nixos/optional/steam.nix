{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;

      gamescopeSession.enable = true;

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
        "--prefer-vkdevice" # 优化 Vulkan 设备切换
      ];
    };
    gamemode.enable = true;  # 启用Gamemode，并自动激活以动态提升性能
  };

  environment.systemPackages = with pkgs; [
    lutris  # 支持多游戏平台
    gamemode # 提升游戏性能动态管理
    mangohud # 游戏 HUD 显示帧率等信息
    steam-run  # 运行非原生Steam游戏
    protonplus  # Simple Wine and Proton-based compatibility tools manager
  ];
}