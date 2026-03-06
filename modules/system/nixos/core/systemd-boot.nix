{ pkgs, ... }:
{
  boot = {
    #开启cake+bbr
    kernel.sysctl = {
      "net.core.default_qdisc" = "cake"; # Zen 内核完美支持
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3; # 额外加成：减少网页握手延迟
    };

    # 核心系统配置
    #kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    supportedFilesystems = ["ntfs"];
    kernelParams = [
      # 基础优化
      "loglevel=3"
      "quiet"
      "splash"
      "console=tty1"
      "lru_gen=y" # for cachyosKernel
      "transparent_hugepage=madvise"  # 允许使用大页
      
      # nvidia驱动相关
      "module_blacklist=nova_core,nova,nouveau"
      "nvidia-drm.modeset=1"

      # intel集显相关
      "i915.enable_guc=3"      # 开启调度和视频加速
      "i915.enable_fbc=1"      # 帧缓冲压缩
      "i915.enable_psr=0"      # 禁用 PSR 防止 Wayland 闪屏
      "i915.guc_log_level=-1"  # 禁用日志，减少中断负担
    ];
    initrd.verbose = false;
    #initrd.kernelModules = [ "nvidia" ];
    
    # systemd-boot 引导加载器配置
    loader = {
      systemd-boot.enable = true; 
      grub.enable = false;

      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint  = "/boot";

      systemd-boot.configurationLimit = 10;
    };
    
    plymouth.enable = true;
  };
}
