
{ config, pkgs, ... }:

{
  services.tomcat = {
    enable = true;                    # 启用服务
    # package = pkgs.tomcat10;        # 可选：切换版本（支持 tomcat9、tomcat10 等）
    port = 8088;                      # 默认端口，可改
    purifyOnStart = true;             # 强烈推荐！每次启动清理旧配置，避免冲突
    baseDir = "/var/tomcat";          # 默认数据目录（conf、webapps、logs 等都在这里）

    # 部署你的 WAR 应用（支持 .war 文件或目录）
    webapps = [ config.services.tomcat.package.webapps ] ++ [
      # ./myapp.war                # 把你的 WAR 文件放配置文件同目录
      # "/absolute/path/to/your/app"  # 或目录形式
    ];

    # JVM 参数示例（可选）
    catalinaOpts = "-Xmx512m -XX:+UseG1GC";
    # javaOpts = "-Dfile.encoding=UTF-8";
  };

  # 开放防火墙（必须）
  networking.firewall.allowedTCPPorts = [ 8088 ];
}