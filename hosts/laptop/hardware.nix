{ config, pkgs, ... }:
{
  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # 1. 核心 NVIDIA 驱动设置
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # 2. 屏蔽冲突驱动
  boot.blacklistedKernelModules = [
    "nouveau"
    "nova_core"
    "nova"
    "nvidiafb"
  ];

  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  # 3. PRIME 卸载配置
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
