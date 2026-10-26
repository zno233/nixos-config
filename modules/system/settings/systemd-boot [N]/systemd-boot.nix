{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  flake.modules.nixos.systemd-boot =
    {
      pkgs,
      ...
    }:
    {
      nixpkgs = {
        overlays = [
          inputs.nix-cachyos-kernel.overlays.pinned
        ];
      };

      boot = {
        kernel.sysctl = {
          # Disable the NMI watchdog.
          # Reduces a small amount of overhead and power consumption,
          # at the cost of losing this particular watchdog facility.
          "kernel.nmi_watchdog" = 0;

          # Allow unprivileged user namespaces.
          # CachyOS enables this for container/application compatibility.
          "kernel.unprivileged_userns_clone" = 1;

          # Reduce kernel messages printed to the console.
          "kernel.printk" = "3 3 3 3";

          # Restrict exposure of kernel pointers.
          "kernel.kptr_restrict" = 2;

          # 允许挂死时安全重启（对齐 CachyOS）
          "kernel.sysrq" = 1;

          # Increase network device receive backlog.
          # Useful mainly under bursty/high-throughput traffic.
          "net.core.netdev_max_backlog" = 4096;

          # Maximum number of file handles.
          "fs.file-max" = 2097152;

          # 提高 inotify 文件监视器上限，防止 Vite 等前端开发工具报 ENOSPC 错误
          # Linux 默认值为 8192，对现代前端项目（node_modules 文件众多）远远不够
          "fs.inotify.max_user_watches" = 524288;

          #开启cake+bbr
          "net.core.default_qdisc" = "cake"; # 低延迟公平分配
          "net.ipv4.tcp_congestion_control" = "bbr"; # 高效利用带宽
          "net.ipv4.tcp_fastopen" = 3; # 减少握手延迟

          # 缓冲区调整，内核自己动态调整就行
          # "net.ipv4.tcp_rmem" = "4096 1048576 2097152"; # min/default/max；2MB max适合大多数链路
          # "net.ipv4.tcp_wmem" = "4096 65536 16777216";
          # "net.core.rmem_max" = 2097152;
          # "net.core.wmem_max" = 16777216;

          # 启用ECN
          # "net.ipv4.tcp_ecn" = 1;
        };

        # 核心系统配置
        #kernelPackages = pkgs.linuxPackages_zen;
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
        # supportedFilesystems = [ "ntfs3" ];
        kernelParams = [
          # 基础优化
          "quiet"
          # "loglevel=3"
          # "splash"
          "console=tty1"
          # 无需手动启用 lru_gen / transparent_hugepage，
          # CachyOS 内核已默认开启 MGLRU（0x0007）与 THP=always（defer+madvise）
          # split_lock_mitigate=0、watermark_boost_factor=0 亦为内核默认
        ];
        consoleLogLevel = 3;
        # initrd.kernelModules = [ "nvidia" ];

        # systemd-boot 引导加载器配置
        loader = {
          systemd-boot.enable = true;
          grub.enable = false;

          efi.canTouchEfiVariables = true;
          efi.efiSysMountPoint = "/boot";

          systemd-boot.configurationLimit = 8;
        };

        plymouth.enable = true;
      };

      # 对齐 CachyOS blacklist.conf：拉黑硬件 watchdog，省电且减少中断负担
      # （nmi_watchdog 已关，模块级 watchdog 一并屏蔽；sp5100 为 AMD 通用规则）
      boot.blacklistedKernelModules = [
        "iTCO_wdt"
        "wdat_wdt"
        "sp5100_tco"
      ];

      # 进程 fd 上限对齐 CachyOS 10-limits.conf：soft 2048 → hard 2097152
      # 大型 dev 工具链/多 fd 服务不再受 hard limit 克制
      systemd.settings.Manager.DefaultLimitNOFILE = "2048:2097152";
    };
}
