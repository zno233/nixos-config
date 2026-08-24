{
  flake.modules.nixos.systemd-boot =
    { pkgs, ... }:
    {
      boot = {
        kernel.sysctl = {
          # 提高 inotify 文件监视器上限，防止 Vite 等前端开发工具报 ENOSPC 错误
          # Linux 默认值为 8192，对现代前端项目（node_modules 文件众多）远远不够
          "fs.inotify.max_user_watches" = 524288;

          #开启cake+bbr
          "net.core.default_qdisc" = "cake"; # 低延迟公平分配
          "net.ipv4.tcp_congestion_control" = "bbr"; # 高效利用带宽
          "net.ipv4.tcp_fastopen" = 3; # 减少握手延迟

          # 缓冲区调整
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
          # "lru_gen=y" # 启用 MGLRU
          # "transparent_hugepage=madvise" # 允许使用大页
        ];
        initrd.verbose = false;
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
    };
}
