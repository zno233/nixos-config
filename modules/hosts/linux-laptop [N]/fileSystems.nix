{
  flake.modules.nixos.linux-laptop =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      # 1. 启用 ntfs 支持
      boot.supportedFilesystems = [
        "ntfs"
      ];

      # 2. 挂载 Windows 系统分区 (nvme0n1p3)
      fileSystems."/mnt/windows" = {
        device = "/dev/disk/by-uuid/ACA44607A445D48C"; # Windows 系统分区 UUID
        fsType = "ntfs3";
        options = [
          "defaults"
          "nofail"
          "ro" # **重要：建议只读**
          "x-gvfs-show" # 告诉 Nemo/GVFS 显示该设备
        ];
      };

      # 3. 挂载 Data 数据分区 (nvme0n1p4)
      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/A2F62AC3F62A9815"; # Data 分区 UUID
        fsType = "ntfs3";
        options = [
          "defaults"
          "nofail"
          "uid=1000" # 将 1000 替换为你自己的用户 ID
          "gid=100" # 将 100 替换为你自己的主用户组 ID
          "umask=007" # 设置权限
          "x-gvfs-show" # 告诉 Nemo/GVFS 显示该设备
        ];
      };

      # 4. 声明 Swap 设备（使用ZRAM时需禁用以防LRU反转）
      # swapDevices = [
      #   {
      #     device = "/var/lib/swapfile";
      #     size = 8 * 1024; # 8 GiB (8192 MiB)，单位是 MiB
      #     # 可选：randomEncryption = true;  # 如果需要加密 swap
      #   }
      # ];
    };
}
