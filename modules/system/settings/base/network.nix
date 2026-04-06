{
  flake.modules.nixos.network =
    { pkgs, ... }:
    {
      networking = {
        nftables.enable = true;
        nameservers = [
          "223.6.6.6"
          "8.8.8.8"
          "8.8.4.4"
          "1.1.1.1"
        ];
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
          # 可选：启用 WiFi 节能（笔记本推荐）
          # wifi.powersave = true;
        };
        firewall = {
          enable = true;
          backend = "nftables";
          allowedTCPPorts = [
            22
            80
            443
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
            DNSOverTLS = "opportunistic";
            domains = [ "~." ];
            FallbackDNS = [
              "8.8.8.8"
              "1.1.1.1"
            ];
          };
        };
      };

      environment.systemPackages = with pkgs; [ networkmanagerapplet ];
    };
}
