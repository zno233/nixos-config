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

            # aliyun dns
            DNS = [ "223.6.6.6" ];

            # 备用 DNS
            FallbackDNS = [
              "1.1.1.1" # Cloudflare DNS
              "8.8.8.8" # Google DNS
            ];

            DNSStubListener = "no";
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
