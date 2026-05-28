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
          # "balanced" 通常是笔记本的最佳平衡点，兼顾性能和电池寿命
          # 如果更看重电池续航，可以改为 "powersave"
          ppdSettings = {
            main = {
              default = "balanced";
              battery_detection = true;
            };
            # 将 GNOME/KDE 的电源模式滑块映射到你的硬件最佳 Profile
            profiles = {
              power-saver = "laptop-battery-powersave"; # 对应滑块“省电”
              balanced = "balanced-battery"; # 对应滑块“平衡”
              performance = "desktop"; # 对应滑块“高性能”
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
          cpupower
        ];
      };
    };
}
