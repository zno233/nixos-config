{
  flake.modules.nixos.zram =
    {
      lib,
      ...
    }:
    {
      # Zram 配置：纯内存压缩方案
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        # 16G 内存，zstd 压缩比通常 2:1~3:1，100% 是合理选择
        # （若为 32G+ 内存，建议降至 50% 左右，避免元数据开销和极端 OOM 风险）
        memoryPercent = 100;
        priority = 100;
      };
      # 内核内存管理参数
      boot.kernel.sysctl = {
        # Swappiness：zram 场景下优先换出匿名页，保留文件页缓存
        # 由于 swap 介质是内存压缩而非磁盘，换出代价远低于传统 swap
        # 社区(ChromeOS/Fedora)常用 150 左右，
        # 让冷匿名页更积极地进 zram，减少不必要的文件缓存驱逐
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
