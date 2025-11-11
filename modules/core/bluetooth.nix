{ config, pkgs, ... }:

{
  # 核心蓝牙服务 (BlueZ)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # 开机默认关闭蓝牙，省电
  };

  # 图形化管理工具 (Blueman)
  # 适用于 Hyprland 和所有桌面环境/窗口管理器
  services.blueman.enable = true;
  
  # 蓝牙功能本身不需要额外的系统包
  environment.systemPackages = [ ];
}
