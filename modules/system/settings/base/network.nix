{
  flake.modules.nixos.network =
    { pkgs, ... }:
    {
      networking = {
        nftables.enable = true;
        
        # 所有 DNS 查询指向本地 127.0.0.1:53
        # daed 会通过 bind: 'tcp+udp://0.0.0.0:53' 监听这个端口并接管所有查询
        nameservers = [
          "127.0.0.1"
        ];
        
        networkmanager = {
          enable = true;
          # 使用 systemd-resolved 管理 DNS
          # 但实际查询会被 daed 拦截（因为 nameservers 指向 127.0.0.1）
          dns = "systemd-resolved";
        };
        
        firewall = {
          enable = true;
          backend = "nftables";
          allowedTCPPorts = [
            22    # SSH
            80    # HTTP
            443   # HTTPS
            59010
            59011
          ];
          allowedUDPPorts = [
            59010
            59011
          ];
        };
      };
      
      # 关闭 systemd-resolved 服务，这会导致dns泄露
      services.resolved = {
        enable = true;
        settings = {
          Resolve = {
            # 关闭 DNS over TLS，让 daed 统一处理所有 DNS
            DNSOverTLS = "no";
            
            # 搜索域配置
            domains = [ "~." ];
            
            # 备用 DNS
            FallbackDNS = [
              "223.6.6.6"  # 阿里 DNS
              "8.8.8.8"    # Google DNS
              "8.8.4.4"    # Google DNS 备用
              "1.1.1.1"    # Cloudflare DNS
            ];
            
            # 关键：让 systemd-resolved 不占用 53 端口
            # 这样 daed 才能通过 bind: 'tcp+udp://0.0.0.0:53' 监听该端口
            DNSStubListener = "no";
          };
        };
      };
      
      environment.systemPackages = with pkgs; [ networkmanagerapplet ];
    };
}