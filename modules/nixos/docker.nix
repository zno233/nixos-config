{ config, pkgs, ... }:

{
  # 启用 Docker 虚拟化模块
  virtualisation.docker.enable = true;
  
  # 启用无根模式 (Rootless Mode)
  virtualisation.docker.rootless = {
    enable = true;
    # 启用此项后，NixOS 会自动设置 DOCKER_HOST 环境变量，
    # 指向用户级别的 Docker 守护进程，方便使用。
    setSocketVariable = true; 
  };
  
  # 注意：在无根模式下，不需要将用户添加到 "docker" 组。
  # Docker 守护进程以普通用户身份运行。
}
