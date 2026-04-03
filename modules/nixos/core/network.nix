{ pkgs, meta, ... }:
{
  networking = {
    nftables.enable = true;
    hostName = "${meta.hostName}";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved"; # 明确交给 resolved 处理，避免冲突
    };
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
    firewall = {
      enable = true;
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
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";
        Domains = [ "~." ];
        # FallbackDNS = [
        #   "8.8.8.8"
        #   "8.8.4.4"
        #   "1.1.1.1"
        # ];
      };
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
