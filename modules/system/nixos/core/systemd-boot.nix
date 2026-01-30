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
      "loglevel=3"
      "quiet"
      "splash"
      "console=tty1"
      "module_blacklist=nova_core,nova,nouveau"
      "i915.enable_psr=0"
      "nvidia-drm.modeset=1"
      "lru_gen=y" #for cachyosKernel
    ];
    consoleLogLevel = 0;
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
