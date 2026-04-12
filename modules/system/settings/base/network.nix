{
  flake.modules.nixos.network =
    { pkgs, ... }:
    {
      networking = {
        nftables.enable = true;
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };

        # nameservers = [
        #   "127.0.0.1" # daed
        #   "223.6.6.6" # 阿里云 DNS
        #   "8.8.8.8" # Google DNS
        #   "8.8.4.4" # Google DNS 备用
        #   "1.1.1.1" # Cloudflare DNS
        # ];

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

            # 所有 DNS 查询指向本地 127.0.0.1:5353
            DNS = [ "127.0.0.1:5353" ];

            # 备用 DNS
            FallbackDNS = [
              "223.6.6.6" # 阿里云 DNS
              "1.1.1.1" # Cloudflare DNS
              "8.8.8.8" # Google DNS
            ];

            DNSStubListener = "yes";
            DNSSEC = "allow-downgrade";
            # DNSOverTLS = "opportunistic";
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
