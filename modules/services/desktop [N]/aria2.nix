{
  config,
  lib,
  ...
}:
let
  mainUser = config.flake.meta.mainUser.name;
  homeDir = config.flake.meta.mainUser.homeDirectory;
in
{
  flake.modules.nixos.aria2 =
    { config, ... }:
    {
      services.aria2 = {
        enable = true;
        rpcSecretFile = config.age.secrets.aria2-rpc-secret.path;
        openPorts = true; # 自动开 RPC 6800 + listen-port 6881-6889

        # 下载目录对 aria2 用户组可写
        downloadDirPermission = "0775";
        serviceUMask = "0002";

        settings = {
          dir = "${homeDir}/Downloads/aria2-download";

          "rpc-allow-origin-all" = true;

          # DHT 端口：模块 freeform 只接受标量（bool/int/float/str），不能用列表
          "dht-listen-port" = 6881;
          # listen-port 必须是列表格式（模块的 typed option），UDP DHT 监听范围
          "listen-port" = [
            {
              from = 6881;
              to = 6889;
            }
          ];

          # BT / PEX
          "enable-dht" = true;
          "enable-peer-exchange" = true;
          "bt-enable-lpd" = true;
          "bt-enable-metadata-only" = false;
          "follow-torrent" = true;

          # HTTP 多线程：16 是大多数 CDN 的兼容上限
          "split" = 16;
          "max-connection-per-server" = 16;
          "min-split-size" = "1M";
          "max-concurrent-downloads" = 5;

          # 容错：失败重试 + 慢速源剔除
          "max-tries" = 5;
          "retry-wait" = 3;
          "timeout" = 60;
          "connect-timeout" = 30;
          "lowest-speed-limit" = "100K";

          # 传输行为
          "continue" = true;
          "file-allocation" = "falloc";
          "stream-piece-selector" = "geom";
          "http-accept-gzip" = true;
          "content-disposition-default-utf8" = true;
          "check-integrity" = true;
          "allow-overwrite" = true;
          "auto-file-renaming" = false;

          # 伪装浏览器 UA，避免 CDN 识别为爬虫限速/拦截
          "user-agent" = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36";

          # tracker：模块 settings 的 freeform 类型是 singleLineStr，不能用多行字符串，
          # 必须全部写在同一行用逗号分隔（与 aria2c 的 --bt-tracker 分隔符一致）
          "bt-tracker" = "https://tracker.openbittorrent.com:80/announce,https://tracker.opentrackr.org:1337/announce,https://open.stealth.si:80/announce,https://tracker.torrent.eu.org:443/announce,https://open.demonii.com:1337/announce,https://explodie.org:6969/announce,https://tracker.tiny-vps.com:6969/announce,https://tracker1.bt.moack.co.kr:6969/announce,https://tracker.files.fm:6969/announce,https://tracker.gbitt.info:443/announce";
        };
      };

      users.users.${mainUser}.extraGroups = [ "aria2" ];

      # ACL：给 aria2 用户穿越目录的执行权限(x)，不给读权限(r)，不暴露其他文件
      systemd.tmpfiles.rules = [
        "a ${homeDir} - - - - u:aria2:x"
        "a ${homeDir}/Downloads - - - - u:aria2:x"
      ];
    };
}
