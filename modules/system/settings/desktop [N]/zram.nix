{
  flake.modules.nixos.zram =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # Zram 配置：纯内存压缩方案
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
        priority = 100;
      };

      # 内核内存管理参数
      boot.kernel.sysctl = {
        # Swappiness：桌面系统推荐 60-80
        # 60 = 在内存压力下主动使用 zram，但不会过度激进
        "vm.swappiness" = "60";

        # 内存回收水位线：保守设置，避免过早回收
        "vm.watermark_boost_factor" = "0";
        "vm.watermark_scale_factor" = "125";

        # 页簇（page cluster）：zram 应该设为 0
        # 禁用预读，因为 zram 是随机访问，预读无益
        "vm.page-cluster" = "0";

        # 脏页策略：适合 SSD 的平衡配置
        "vm.dirty_background_ratio" = "10"; # 后台写入阈值
        "vm.dirty_ratio" = "20"; # 强制写入阈值
        "vm.dirty_expire_centisecs" = "3000"; # 30 秒过期
        "vm.dirty_writeback_centisecs" = "500"; # 5 秒回写间隔

        # VFS 缓存压力：50 是合理值，保护 inode/dentry 缓存
        "vm.vfs_cache_pressure" = "100";

        # 内存碎片整理阈值
        "vm.extfrag_threshold" = "500";

        # 减少内存碎片，改善 zram 压缩效果
        "vm.compaction_proactiveness" = "20"; # 主动内存整理
        "vm.min_free_kbytes" = "131072"; # 保留 128MB 自由内存
      };

      # NVMe I/O 调度器（none）
      services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
      '';

      # 显式禁用磁盘 swap
      swapDevices = lib.mkForce [ ];
    };
}
