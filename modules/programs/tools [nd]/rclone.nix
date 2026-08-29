{
  flake.modules.homeManager.rclone =
    { config, pkgs, ... }:
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
      systemd.user.services.rclone-webdav = {
        Unit = {
          Description = "Rclone WebDAV Mount";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
          StartLimitIntervalSec = "60s";
          StartLimitBurst = 3;
        };
        Service = {
          Type = "notify";
          # 自动创建挂载目录（防止因目录不存在而启动失败）
          # 启动前检查配置文件是否存在
          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}"
            "${pkgs.runtimeShell} -c 'test -f ${configFile}'"
          ];

          # 参数注释说明：
          # --vfs-cache-mode full : 开启完整缓存，极大地优化视频拖拽播放
          # --vfs-cache-max-size 5G : 限制缓存占用空间
          # --vfs-cache-max-age 24h : 缓存有效期
          # --buffer-size 32M : 增加缓冲区，提升视频流畅度
          # --dir-cache-time 1h : 缓存目录结构，提升浏览速度
          # --contimeout 10s : 连接超时 10 秒，网络差时快速失败
          # --timeout 30s : 整体操作超时 30 秒
          # --rc 开启远程控制接口
          # --rc-addr 127.0.0.1:5572 指定监听地址，只绑定本地回环避免暴露到公网
          # --rc-no-auth 跳过认证, 这在只绑定本地回环地址的情况下是安全的
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount webdav-remote:/ ${mountPoint} \
              --config ${configFile} \
              --vfs-cache-mode full \
              --vfs-cache-max-size 5G \
              --vfs-cache-max-age 24h \
              --buffer-size 32M \
              --dir-cache-time 1h \
              --contimeout 10s \
              --timeout 30s \
              --log-level INFO \
              --rc \
              --rc-addr 127.0.0.1:5572 \
              --rc-no-auth
          '';

          # 动态指定卸载路径
          ExecStop = "/run/wrappers/bin/fusermount -u ${mountPoint}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
