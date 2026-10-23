# Enable honk — module now lives upstream: github:zno233/nix-packages (nixosModules.honk)
{ config, inputs, ... }:
let
  homeDir = config.flake.meta.mainUser.homeDirectory;
in
{
  flake.modules.nixos.honk =
    { pkgs, ... }:
    {
      imports = [ inputs.nix-packages.nixosModules.honk ];

      services.honk-core = {
        enable = true;
        configFile = "${homeDir}/.config/honk/config.dae"; # 任意绝对路径
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
