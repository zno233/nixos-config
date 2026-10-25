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
          allowedTCPPorts = [ 22 ];
        };
      };

      services.resolved = {
        enable = true;
        settings = {
          Resolve = {
            # 搜索域配置
            # Domains = [ "~." ];

            DNS = [
              "223.5.5.5#dns.alidns.com"
              "223.6.6.6#dns.alidns.com"
            ];

            FallbackDNS = [
              "1.1.1.1#cloudflare-dns.com"
              "8.8.8.8#dns.google"
            ];

            DNSStubListener = "yes";
            DNSSEC = "no";
            DNSOverTLS = "opportunistic";
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
