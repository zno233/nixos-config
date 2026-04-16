{
  flake.modules.nixos.zram =
    {
      lib,
      ...
    }:
    {
      # Zram 配置：纯内存压缩方案，尽量接近cachyos的配置
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
        priority = 100;
      };

      # 内核内存管理参数
      boot.kernel.sysctl = {
        # Swappiness：zram 场景下优先换出匿名页，保留文件页缓存
        "vm.swappiness" = "150";

        # 页簇（page cluster）：zram 应该设为 0
        # 禁用预读，因为 zram 是随机访问，预读无益
        "vm.page-cluster" = "0";

        # 脏页策略：使用固定字节值，避免高内存压力下 ratio 计算失准
        "vm.dirty_background_bytes" = "67108864"; # 64MB 后台写入阈值
        "vm.dirty_bytes" = "268435456"; # 256MB 强制写入阈值
        "vm.dirty_writeback_centisecs" = "1500"; # 15 秒回写间隔

        # VFS 缓存压力：50 是合理值，保护 inode/dentry 缓存
        "vm.vfs_cache_pressure" = "50";
      };

      # 显式禁用磁盘 swap
      swapDevices = lib.mkForce [ ];

      # 禁用 Zswap
      boot.kernelParams = [ "zswap.enabled=0" ];
    };
}
