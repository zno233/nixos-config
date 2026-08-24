{
  flake.modules.nixos.linux-laptop =
    { config, pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
      ];

      # 允许非自由软件
      nixpkgs.config.allowUnfree = true;

      # 1. 核心 NVIDIA 驱动设置
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
      # 1.1 启用 NVIDIA 容器工具包
      hardware.nvidia-container-toolkit.enable = true;

      # 1.2 X server 视频驱动(从共享 xserver.nix 移入的平台特定配置)
      services.xserver.videoDrivers = [
        "modesetting"
        "nvidia"
      ];

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

      # 4. Intel 核显 VA-API 支持
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver # VA-API
        vpl-gpu-rt
      ];

      # 32 位 VA-API 包
      hardware.graphics.extraPackages32 = [
        pkgs.pkgsi686Linux.intel-media-driver # 32 位 VA-API
      ];
    };
}
