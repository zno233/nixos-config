{
  flake.modules.nixos.scx =
    { config, pkgs, ... }:

    {
      # 1. 基础服务：开启SCX
      services.scx.enable = true;
      services.scx.scheduler = "scx_bpfland";

      # 2. 状态同步：确保电池开机时不会自动启动 SCX
      # ConditionACPower 会让服务在没插电时处于 "condition failed" 状态而不运行
      systemd.services.scx.unitConfig.ConditionACPower = "yes";

      # 3. 针对 ACAD 节点的 Udev 切换规则
      services.udev.extraRules = ''
        # 匹配 KERNEL=="ACAD" 确保只监听适配器的插拔
        # 插电 (online 为 1) -> 启动
        SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start scx.service"

        # 拔电 (online 为 0) -> 停止
        SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl stop scx.service"
      '';
    };
}
