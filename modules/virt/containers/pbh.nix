{
  config,
  inputs,
  ...
}:
let
  homeDir = config.flake.meta.mainUser.homeDirectory;
in
{
  flake.modules.nixos.containers =
    { ... }:
    {
      # 导入 PBH 用户级模块
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.pbh
      ];

      # === 声明式部署 PBH 系统级 Quadlet ===
      environment.etc."containers/systemd/peerbanhelper.container".text = ''
        [Unit]
        Description=PeerBanHelper (System-level Quadlet)
        After=network-online.target
        Wants=network-online.target
        Requires=network-online.target

        [Container]
        Image=ghostchu/peerbanhelper:latest
        ContainerName=peerbanhelper
        Volume=${homeDir}/pbh-data:/app/data:rw
        Network=host
        Environment=TZ=Asia/Shanghai

        [Service]
        Restart=always
        TimeoutStartSec=300

        # [Install]
        # WantedBy=multi-user.target
      '';

      # 声明式创建数据目录
      systemd.tmpfiles.rules = [
        "d ${homeDir}/pbh-data 0755 zno users -"
      ];

      # 防火墙开放 Web 界面
      networking.firewall.allowedTCPPorts = [ 9898 ];
    };

  flake.modules.homeManager.pbh =
    { ... }:
    {
      # 添加一些 ZSH 别名
      programs.zsh.shellAliases = {
        pbh-start = "sudo systemctl start peerbanhelper";
        pbh-stop = "sudo systemctl stop peerbanhelper";
        pbh-restart = "sudo systemctl restart peerbanhelper";
        pbh-status = "sudo systemctl status peerbanhelper --no-pager -l";
        pbh-logs = "sudo journalctl -u peerbanhelper -f";
      };
    };
}
