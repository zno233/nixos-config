# Enable honk — module definition lives with the package: pkgs/apps/honk/module.nix
# (services.honk is reserved by nixpkgs rename.nix; this module uses services.honk-core)
{
  flake.modules.nixos.honk =
    { pkgs, ... }:
    {
      imports = [ ../../../pkgs/apps/honk/module.nix ];

      services.honk-core = {
        enable = true;
        configFile = "/home/zno/.config/honk/config.dae"; # 任意绝对路径
        # serves doona at http://127.0.0.1:9527/ui/ (native_api include auto-wired)
        ui = pkgs.doona;
        assets = with pkgs; [
          v2ray-geoip
          v2ray-domain-list-community
        ];
        openFirewall = {
          enable = true;
          port = 12345; # dae 的 tproxy_port，根据您的 config.dae 调整
        };
      };
    };
}
