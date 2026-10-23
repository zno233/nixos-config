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
      lib,
      pkgs,
      ...
    }:
    {
      nixpkgs = {
        overlays = [
          inputs.nix-cachyos-kernel.overlays.pinned

          # 新版 nixpkgs 的 aggregateModules 无条件合并 modules.cer 与外部模块的
          # .ko.cer 文件，而 release 分支的 pinned CachyOS 内核及其模块包
          # （nvidia、acpi_call 等）都不生成它们，导致聚合构建失败
          # （xddxdd/nix-cachyos-kernel#111）。此处：
          # 1) 聚合前为缺失的 modules.cer 建一个指向 /dev/null 的软链
          #    （stock 的 cp --remove-destination 随后会把它替换成空的普通文件）；
          # 2) 把合并外部 .ko.cer 的 xargs cat 换成跳过不存在文件的循环。
          # 若 nixpkgs 改写了 xargs 那一行会 throw 提醒更新本 workaround。
          (final: prev: {
            aggregateModules =
              modules:
              let
                patch =
                  drv:
                  drv.overrideAttrs (
                    old:
                    let
                      orig = old.postBuild or "";
                      search = "xargs -d'\\n' cat >> modules.cer";
                      repl = "while IFS= read -r _f; do if [ -e \"$_f\" ]; then cat \"$_f\"; fi; done >> modules.cer";
                      patched = builtins.replaceStrings [ search ] [ repl ] orig;
                    in
                    if !lib.hasInfix search orig then
                      throw "zno-config: aggregateModules 的 xargs cat 代码段已变动，请更新或删除 systemd-boot.nix 中的 modules.cer workaround（xddxdd/nix-cachyos-kernel#111）"
                    else
                      {
                        postBuild = ''
                          if [ -d "$out/lib/modules" ]; then
                            for _d in "$out"/lib/modules/*; do
                              [ -d "$_d" ] || continue
                              if [ ! -e "$_d/modules.cer" ] && [ ! -L "$_d/modules.cer" ]; then
                                ln -s /dev/null "$_d/modules.cer"
                              fi
                            done
                          fi
                        ''
                        + patched;
                      }
                  );
                base = prev.aggregateModules modules;
              in
              (patch base)
              // {
                override = args: patch (base.override args);
              };
          })
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
