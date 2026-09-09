{
  flake.modules.nixos.network =
    {
      pkgs,
      ...
    }:
    {
      networking = {
        nftables.enable = true;
        networkmanager = {
          enable = true;
          wifi = {
            # 启用 iwd 作为 NetworkManager 的无线后端
            backend = "iwd";
            # 避免与 iwd 竞争改写 MAC 导致断连
            # macAddress = "stable-ssid";
          };
          dns = "systemd-resolved";
        };

        # nameservers = [
        #   "223.6.6.6" # 阿里云 DNS
        #   "8.8.8.8" # Google DNS
        #   "8.8.4.4" # Google DNS 备用
        #   "1.1.1.1" # Cloudflare DNS
        # ];

        wireless.iwd = {
          enable = true;
          settings = {
            # network 表示对每个 SSID 使用固定的生成 MAC 地址 (相当于 stable-ssid)
            General.AddressRandomization = "network";
          };
        };

        firewall = {
          enable = true;
          backend = "nftables";
          allowedTCPPorts = [
            22 # SSH
            80 # HTTP
            443 # HTTPS
            59010
            59011
          ];
          allowedUDPPorts = [
            59010
            59011
          ];
        };
      };

      services.resolved = {
        enable = true;
        settings = {
          Resolve = {
            # 搜索域配置
            # Domains = [ "~." ];

            # aliyun dns
            DNS = [ "223.6.6.6" ];

            # 备用 DNS
            FallbackDNS = [
              "1.1.1.1" # Cloudflare DNS
              "8.8.8.8" # Google DNS
            ];

            DNSStubListener = "yes";
            DNSSEC = "allow-downgrade";
            DNSOverTLS = "no";
            Cache = "yes";
            CacheFromLocalhost = "yes";
            LLMNR = "no";
            MulticastDNS = "no";
          };
        };
      };

      environment.systemPackages = with pkgs; [ networkmanagerapplet ];
    };
}
