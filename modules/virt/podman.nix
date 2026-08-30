{
  inputs,
  ...
}:
{
  flake.modules.nixos.podman =
    { pkgs, ... }:
    {
      # 导入声明式的容器配置
      imports = with inputs.self.modules.nixos; [
        containers
      ];

      virtualisation.podman = {
        enable = true;
        dockerCompat = true; # 命令别名
        dockerSocket.enable = true; # 模拟 Docker daemon 的 socket 接口
        defaultNetwork.settings.dns_enabled = true;
        # 自动清理无用容器/镜像/网络（每周日凌晨 3 点）
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [ "--all" ];
        };

      };

      # 为用户 zno 配置 subuid/subgid（必须）
      users.users."zno" = {
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
        # 可选：如果你想让该用户开机自动启动用户服务
        # linger = true;
      };

      environment.systemPackages = with pkgs; [
        distrobox
        podman-compose # Docker Compose 兼容工具
      ];

      # 可选：让普通用户能管理 podman 相关 socket
      # security.wrappers.newuidmap.source = "${pkgs.shadow}/bin/newuidmap";
      # security.wrappers.newgidmap.source = "${pkgs.shadow}/bin/newgidmap";
    };
}
