{ pkgs, config,inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
    ./hardware.nix
    ./fileSystems.nix
  ];

  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    powertop
  ];

  services = {
    # 已注释 power-profiles-daemon，避免与 TLP 冲突，这是正确的做法。
    # power-profiles-daemon.enable = true;

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    tlp = {
      enable = true;
      settings = {
        # 核心CPU能耗性能策略：
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # CPU 睿频 (Turbo Boost)：
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        # 硬件 P-States 动态睿频：
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        # 平台电源配置文件（固件级）：
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # Intel 核显最低频率：
        INTEL_GPU_MIN_FREQ_ON_AC = 500;
        INTEL_GPU_MIN_FREQ_ON_BAT = 200;

        # Intel 核显最大频率：
        INTEL_GPU_MAX_FREQ_ON_AC = 1450; # 允许最高频率
        INTEL_GPU_MAX_FREQ_ON_BAT = 1450; # 电池模式下也允许最高频率（可调低以节能）

        # PCIE (PCI Express) 主动状态电源管理 (ASPM)：
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersave"; # 调整为"powersave"以兼容NVMe

        # 新增：CPU频率缩放Governor
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # 新增：CPU最小/最大性能百分比
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 60; # 根据需求调整

        # 新增：NVIDIA独显电源管理
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        NVIDIA_PM_ENABLED = 1; # 如果使用闭源驱动

        # 新增：USB、声音、WiFi优化（移除SATA_LINKPWR，因为磁盘是NVMe，无效）
        USB_AUTOSUSPEND = 1;
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
        WIFI_POWERSAVE_ON_AC = 0;
        WIFI_POWERSAVE_ON_BAT = 1;
        # DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth"; # 可选，禁用启动时设备
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
    #++ [ pkgs.cpupower-gui ];
  };
}
