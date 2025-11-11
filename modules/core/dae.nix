{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.daeuniverse.nixosModules.daed
  ];
  # ------------------------------------------------------------------------
  # dae 服务（使用官方模块）
  # ------------------------------------------------------------------------
  services.dae = {
    enable = true;
    configFile = "/home/zno/.config/dae/config.dae";  # 系统级路径，模块默认
    assets = with pkgs; [ v2ray-geoip v2ray-domain-list-community ];
    openFirewall = {
      enable = true;
      port = 12345;  # dae 的 tproxy_port，根据您的 config.dae 调整
    };
    # 可选：如果需要自定义包
    # package = daeuniverse.packages.${pkgs.system}.dae;  # 默认已使用
    disableTxChecksumIpGeneric = false;  # 默认值，根据需要调整
  };

  systemd.services.dae = lib.mkIf config.services.dae.enable {
    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p /home/zno/.config/dae
      ${pkgs.coreutils}/bin/ln -f ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /home/zno/.config/dae/geoip.dat
      ${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /home/zno/.config/dae/geosite.dat
    '';
    serviceConfig = {
      WorkingDirectory = "/home/zno/.config/dae";
    };
  };

  # ------------------------------------------------------------------------
  # daed 服务（使用官方模块）
  # ------------------------------------------------------------------------
  services.daed = {
    enable = true;
    configDir = "/etc/daed";  # 模块默认
    listen = "127.0.0.1:2025";  # 暴露到所有接口，根据需要调整为 "127.0.0.1:2023" 以限制本地
    openFirewall = {
      enable = true;
     port = 2025;  # daed 的监听端口
    };
    # 可选：如果需要自定义包
    # package = daeuniverse.packages.${pkgs.system}.daed;  # 默认已使用
  #};

  # 确保 daed 依赖于 dae（模块可能已处理，但显式添加）
  #systemd.services.daed = {
  #  after = [ "dae.service" ];
  #  wants = [ "dae.service" ];
  };

  # ------------------------------------------------------------------------
  # 配置文件填充（示例：通过 environment.etc 创建）
  # ------------------------------------------------------------------------
  #environment.etc = {
  #  "dae/config.dae".text = ''
  #    global {
  #      log_level: info
  #      tproxy_port: 12345  # 与 openFirewall.port 匹配
  #      allow_insecure: false
  #      # 其他全局设置...
  #    }
      # 添加 subscription, group, node, routing 等规则...
      # 示例：
  #    subscription {
        # 您的订阅链接...
 #     }
 #     group {
#        # 组定义...
#      }
#      routing {
        # 路由规则...
 #     }
 #   '';

    # 如果 daed 需要配置文件（通常在 UI 中配置，但如果有 YAML）
 #   "daed/config.yaml".text = ''
      # 示例配置，根据 daed 文档调整
#      backend: http://localhost:12345/graphql  # 指向 dae 的 API，如果启用
      # 其他设置...
#    '';
#  };
}
