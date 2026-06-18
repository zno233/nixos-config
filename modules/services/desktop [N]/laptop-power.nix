{
  flake.modules.nixos.laptop-power =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        acpi
        brightnessctl
        cpupower-gui
        powertop
      ];

      services = {
        # intel温控
        thermald.enable = true;

        # 注释 power-profiles-daemon，避免与 TLP 冲突
        # power-profiles-daemon.enable = true;
        upower = {
          enable = true;
          percentageLow = 20;
          percentageCritical = 5;
          percentageAction = 3;
          criticalPowerAction = "PowerOff";
        };

        cpupower-gui.enable = true;

        # tlp = {
        #   enable = true;
        #   settings = {
        #     # 核心CPU能耗性能策略：
        #     CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        #     # CPU 睿频 (Turbo Boost)：
        #     CPU_BOOST_ON_AC = 1;
        #     CPU_BOOST_ON_BAT = 0;

        #     # 硬件 P-States 动态睿频：
        #     CPU_HWP_DYN_BOOST_ON_AC = 1;
        #     CPU_HWP_DYN_BOOST_ON_BAT = 0;

        #     # 平台电源配置文件（固件级）：
        #     PLATFORM_PROFILE_ON_AC = "performance";
        #     PLATFORM_PROFILE_ON_BAT = "low-power";

        #     # PCIE (PCI Express) 主动状态电源管理 (ASPM)：
        #     PCIE_ASPM_ON_AC = "default";
        #     PCIE_ASPM_ON_BAT = "powersave";

        #     # CPU频率缩放Governor
        #     CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        #     # CPU最小/最大性能百分比
        #     CPU_MIN_PERF_ON_AC = 0;
        #     CPU_MAX_PERF_ON_AC = 100;
        #     CPU_MIN_PERF_ON_BAT = 0;
        #     CPU_MAX_PERF_ON_BAT = 80; # 根据需求调整

        #     # 掉电保护：电池模式下加快数据刷盘
        #     MAX_LOST_WORK_SECS_ON_BAT = 15;

        #     # NVIDIA独显电源管理
        #     RUNTIME_PM_ON_AC = "auto";
        #     RUNTIME_PM_ON_BAT = "auto";

        #     # USB、声音、WiFi优化
        #     USB_AUTOSUSPEND = 1;
        #     SOUND_POWER_SAVE_ON_AC = 0;
        #     SOUND_POWER_SAVE_ON_BAT = 1;
        #     WIFI_POWERSAVE_ON_AC = 0;
        #     WIFI_POWERSAVE_ON_BAT = 1;
        #     # DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth"; # 可选，禁用启动时设备
        #   };
        # };

        # 启用 Tuned
        tuned = {
          enable = true;

          # 开启 tuned-ppd 桥接
          # 这能让你的 GNOME/KDE 桌面电池滑块依然完美可用，只是后台运行的是 Tuned
          ppdSupport = true;

          # 设置默认的电源配置文件
          # 对插电模式和电池模式分别设置默认配置
          ppdSettings = {
            main = {
              default = "balanced";
              battery_detection = true;
            };
            profiles = {
              # 插电 (AC) 状态：不考虑电量，追求流畅和极致性能
              power-saver = "desktop-powersave"; # 静音/低温模式：适合夜间下载或安静办公，风扇不叫
              balanced = "desktop"; # 日常主力模式：日常最流畅的体验，响应极快
              performance = "latency-performance"; # 满血模式：编译、游戏、渲染时用，完全释放性能
            };
            battery = {
              # 电池 (Battery) 状态：以续航为主，兼顾流畅度
              power-saver = "laptop-battery-powersave"; # 极致省电：电量告急（<20%）时使用，大幅延长续航
              balanced = "balanced-battery"; # 电池平衡：出门在外的默认模式，小核积极工作
              performance = "desktop"; # 临时爆发：不插电但需要干重活时使用
            };
          };
        };
      };

      # 移除 powerManagement.cpuFreqGovernor 以避免与TLP冲突（TLP已设置governor）
      #powerManagement.cpuFreqGovernor = "performance";
      boot = {
        kernelModules = [ "acpi_call" ];
        extraModulePackages = with config.boot.kernelPackages; [
          acpi_call
        ];
      };
    };
}
