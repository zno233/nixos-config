{
  flake.modules.nixos.network =
    { pkgs, ... }:
    {
      networking = {
        nftables.enable = true;
        networkmanager = {
          enable = true;
          dns = "default";
        };
        nameservers = [
          "127.0.0.1" # daed
          "223.6.6.6" # 阿里云 DNS
          "8.8.8.8" # Google DNS
          "8.8.4.4" # Google DNS 备用
          "1.1.1.1" # Cloudflare DNS
        ];

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

      # services.resolved = {
      #   enable = true;
      #   settings = {
      #     Resolve = {
      #       # 占用 127.0.0.53:53
      #       DNSStubListener = "yes";

      #       # 搜索域配置
      #       domains = [ "~." ];

      #       # 所有 DNS 查询指向本地 127.0.0.1:53
      #       # daed 会通过 bind: 'tcp+udp://0.0.0.0:53' 监听这个端口并接管所有查询
      #       DNS = [ "127.0.0.1" ];

      #       # 备用 DNS
      #       FallbackDNS = [
      #         "223.6.6.6" # 阿里云 DNS
      #         "8.8.8.8" # Google DNS
      #         "8.8.4.4" # Google DNS 备用
      #         "1.1.1.1" # Cloudflare DNS
      #       ];

      #       # DNSSEC = "allow-downgrade";
      #       # DNSOverTLS = "opportunistic";

      #       LLMNR = "no";
      #       MulticastDNS = "no";
      #     };
      #   };
      # };

      environment.systemPackages = with pkgs; [ networkmanagerapplet ];
    };
}
