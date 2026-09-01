{
  flake.modules.nixos.scx =
    { pkgs, ... }:
    {
      services.scx-loader = {
        enable = true;

        schedsPackages = [
          pkgs.scx.rustscheds
        ];

        config = {
          # 开机默认：bpfland
          default_sched = "scx_bpfland";

          # 日常桌面：Auto
          default_mode = "Auto";

          # bpfland 各模式
          scheds.scx_bpfland = {
            # 日常桌面
            auto_mode = [
              "-m"
              "auto"
            ];

            # 游戏
            gaming_mode = [
              "-m"
              "all"
            ];

            # 低延迟模式
            lowlatency_mode = [
              "-m"
              "performance"
              "-w"
            ];

            # 省电
            powersave_mode = [
              "-s"
              "20000"
              "-m"
              "powersave"
              "-I"
              "100"
              "-t"
              "100"
            ];

            # 服务器
            server_mode = [
              "-s"
              "20000"
              "-S"
            ];
          };
        };
      };

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.scx.loader.manage-schedulers"
              && subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';

      # # 电池管理：通过 udev 规则在插电/拔电时自动切换 SCX
      # services.udev.extraRules = ''
      #   # 匹配 KERNEL=="ACAD" 确保只监听适配器的插拔
      #   # 插电 (online 为 1) -> 启动
      #   SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start scx_loader.service"

      #   # 拔电 (online 为 0) -> 停止
      #   SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl stop scx_loader.service"
      # '';
    };
}
