{
  flake.modules.homeManager.rclone =
    {
      config,
      pkgs,
      ...
    }:
    let
      # 动态获取家目录
      homeDir = config.home.homeDirectory;
      mountPoint = "${homeDir}/WebDAV";
      configFile = "${homeDir}/.config/rclone-mount.conf";
    in
    {
      home.packages = with pkgs; [
        rclone
        fuse # 挂载驱动所需的依赖
      ];

      # 把挂载点从 tracker 文件索引中排除,避免后台周期性全量扫描
      dconf.settings = {
        "org/freedesktop/Tracker3/Miner/Files" = {
          ignored-directories = [ "WebDAV" ];
        };
      };

      systemd.user.services.rclone-webdav = {
        Unit = {
          Description = "Rclone WebDAV Mount";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
          StartLimitIntervalSec = "60s";
          StartLimitBurst = 3;
          # 不设 ConditionPathIsMountPoint,完全依赖 ExecStartPre 的强制清理逻辑
          # (avoid stale-mount 误判导致启动被跳过)
        };
        Service = {
          Type = "notify";
          TimeoutStartSec = "30s";

          # 自动创建挂载目录(防止因目录不存在而启动失败)
          # 启动前检查配置文件是否存在
          # 先强制卸载一次(忽略失败),清理上次异常退出留下的僵尸挂载点
          # "-" 前缀表示即使这一步失败也不影响后续步骤继续执行
          ExecStartPre = [
            "-${pkgs.fuse}/bin/fusermount -uz ${mountPoint}"
            "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}"
            "${pkgs.runtimeShell} -c 'test -f ${configFile}'"
          ];

          # 参数注释说明:
          # --vfs-cache-mode writes : 只缓存写入的文件,兼顾性能与磁盘占用
          #   (如果需要视频拖拽播放/seek,可改为 full,但要配合 --no-modtime 使用)
          # --vfs-cache-max-size 5G : 限制缓存占用空间
          # --vfs-cache-max-age 24h : 缓存有效期
          # --vfs-read-chunk-size 32M : 初始读取块大小
          # --vfs-read-chunk-size-limit 512M : 读取块大小上限,越读越大,减少请求次数
          # --vfs-fast-fingerprint : 用更廉价的方式判断文件是否变化,跳过精确 hash 校验
          #   WebDAV 场景下能显著减少目录浏览时的往返请求
          # --no-modtime : 跳过逐文件 modtime 比对,这是导致 Nemo 打开变慢的主因之一
          # --vfs-disk-space-total-size 1T : 固定汇报磁盘总空间,避免每次查询后端配额接口阻塞
          # --buffer-size 32M : 增加缓冲区,提升视频流畅度
          # --dir-cache-time 1h : 缓存目录结构,提升浏览速度
          # --poll-interval 30s : 避免过于频繁的全量目录重扫
          # --attr-timeout 1h : 属性(stat)缓存时间,减少往返请求
          # --contimeout 10s : 连接超时。
          # --timeout 20s : 整体操作超时
          # --low-level-retries 10 : 底层请求失败时的重试次数,恢复到 10
          # --retries 3 : 高层操作失败时的重试次数
          # --webdav-headers "Connection: close" : 强制每次请求都新建连接,不复用旧连接。
          # --rc 开启远程控制接口(仅供 CLI 查询用,如 rclone rc vfs/stats)
          # --rc-addr 127.0.0.1:5572 指定监听地址,只绑定本地回环避免暴露到公网
          # --rc-no-auth 跳过认证,这在只绑定本地回环地址的情况下是安全的
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount webdav-remote:/ ${mountPoint} \
              --config ${configFile} \
              --vfs-cache-mode writes \
              --vfs-cache-max-size 5G \
              --vfs-cache-max-age 24h \
              --vfs-read-chunk-size 32M \
              --vfs-read-chunk-size-limit 512M \
              --vfs-fast-fingerprint \
              --no-modtime \
              --vfs-disk-space-total-size 1T \
              --buffer-size 32M \
              --dir-cache-time 1h \
              --poll-interval 30s \
              --attr-timeout 1h \
              --contimeout 10s \
              --timeout 20s \
              --low-level-retries 10 \
              --retries 3 \
              --log-level INFO \
              --rc \
              --rc-addr 127.0.0.1:5572 \
              --rc-no-auth
          '';

          # 挂载起来后,后台预热目录缓存,避免 Nemo 首次打开时遇到冷启动的完整 listing 请求
          ExecStartPost = [
            "${pkgs.coreutils}/bin/sleep 2"
            "-${pkgs.rclone}/bin/rclone rc vfs/refresh recursive=true --rc-addr 127.0.0.1:5572"
          ];

          # 动态指定卸载路径
          ExecStop = "-${pkgs.fuse}/bin/fusermount -u ${mountPoint}";
          # 兜底:哪怕正常 stop 失败,也强制清理一次挂载点,避免下次启动又踩坑
          ExecStopPost = "-${pkgs.fuse}/bin/fusermount -uz ${mountPoint}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
