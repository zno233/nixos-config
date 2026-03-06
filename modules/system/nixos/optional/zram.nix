{ pkgs, lib, ... }:
{
  # Zram 配置
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    # 核心内存调度：积极压缩冷数据，保护 Page Cache
    "vm.swappiness" = "150"; 
    "vm.watermark_boost_factor" = "0"; 
    "vm.watermark_scale_factor" = "125";
    "vm.page-cluster" = "0"; 

    # 脏页策略调整
    "vm.dirty_background_ratio" = "5";
    "vm.dirty_ratio" = "10";
    "vm.dirty_expire_centisecs" = "1500"; # 15秒强制落地
    "vm.dirty_writeback_centisecs" = "100";
    
    # 文件系统与内存碎片的平衡
    "vm.vfs_cache_pressure" = "50"; 
    "vm.extfrag_threshold" = "500";
    
  };

  # 现代高性能 NVMe SSD 设计的 I/O 调度器：极致的简单与低延迟
  services.udev.extraRules = ''
    # 为 NVMe 硬盘开启 kyber 调度器，降低高负载下的桌面延迟
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="kyber"
  '';
}