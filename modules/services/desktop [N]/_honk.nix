{
  flake-file.inputs = {
    daeuniverse = {
      url = "github:daeuniverse/flake.nix/add-honk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.honk =
    {
      pkgs,
      inputs,
      ...
    }:
    {
      imports = [
        inputs.daeuniverse.nixosModules.honk
      ];
      services.honk = {
        enable = true;
        configFile = "/home/zno/.config/honk/config.dae"; # 任意绝对路径
        assets = with pkgs; [
          v2ray-geoip
          v2ray-domain-list-community
        ];
        openFirewall = {
          enable = true;
          port = 12345;
        };
      };
    };
}
