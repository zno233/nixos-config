{
  flake.modules.homeManager.rclone =
    # 1. 在参数中引入 config
    { config, pkgs, ... }:
    let
      # 2. 动态获取家目录
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
        };
        Service = {
          Type = "notify";
          # 3. 自动创建挂载目录（防止因目录不存在而启动失败）
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";

          # 参数注释说明：
          # --vfs-cache-mode full : 开启完整缓存，极大地优化视频拖拽播放
          # --vfs-cache-max-size 5G : 限制缓存占用空间
          # --vfs-cache-max-age 24h : 缓存有效期
          # --buffer-size 32M : 增加缓冲区，提升视频流畅度
          # --dir-cache-time 1h : 缓存目录结构，提升浏览速度
          # --allow-other : 允许其他用户访问
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
              --log-level INFO \
              --rc \
              --rc-addr 127.0.0.1:5572 \
              --rc-no-auth
          '';

          # 4. 动态指定卸载路径
          ExecStop = "/run/wrappers/bin/fusermount -u ${mountPoint}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      # 若不使用nix管理rclone配置则需要手动通过cli挂载
      # 5.通过 home.file 或 sops/agenix 管理该配置
      # home.file.".config/rclone-mount.conf" = {
      #   text = ''
      #     [webdav-remote]
      #     type = webdav
      #     url = https://your-server/dav
      #     vendor = other
      #     user = your-user
      #     pass = your-encrypted-pass
      #   '';
      # };
    };
}
