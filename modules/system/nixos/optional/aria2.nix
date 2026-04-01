{
  config,
  pkgs,
  lib,
  meta,
  ...
}:
{
  # 1. 确保命令行可用
  environment.systemPackages = with pkgs; [
    aria2
  ];

  # 2. 服务配置
  services.aria2 = {
    enable = true;

    # RPC 密钥文件（必须手动创建一次）
    # sudo mkdir -p /etc/aria2
    # echo "xxxxxxxx" > /etc/aria2/rpc.secret
    # sudo chmod 600 /etc/aria2/rpc.secret
    rpcSecretFile = "/etc/aria2/rpc.secret";

    # 权限优化（让新下载的文件对你的用户组可写）
    downloadDirPermission = "0775";
    serviceUMask = "0002";

    # 所有配置统一写在 settings（dir 必须在里面！）
    settings = {
      dir = "/home/${meta.userName}/Downloads/aria2-download";

      "rpc-allow-origin-all" = true;
      "enable-dht" = true;
      "bt-enable-lpd" = true;

      # DHT 端口（普通整数）
      "dht-listen-port" = 6881;

      # listen-port 必须是列表格式（模块要求）
      "listen-port" = [
        {
          from = 6881;
          to = 6881;
        }
      ];

      # RPC 端口（显式写上更安全）
      "rpc-listen-port" = 6800;
    };
  };

  # 3. 防火墙（模块自动处理）
  services.aria2.openPorts = true; # 自动开 RPC 6800 + listen-port
  networking.firewall.allowedTCPPorts = [ 6881 ]; # BT 下载需要 TCP

  # 4. 用户与权限核心配置
  users.users.${meta.userName} = {
    extraGroups = [ "aria2" ];
  };

  # 5. 精准权限穿透 (ACL 规则)
  # 原理：让 aria2 用户拥有沿途目录的执行权限(x)，但无法读取(r)你的其他文件
  systemd.tmpfiles.rules = [
    # 给 aria2 用户穿透权限
    "a /home/${meta.userName} - - - - u:aria2:x"
    "a /home/${meta.userName}/Downloads - - - - u:aria2:x"
  ];
}
