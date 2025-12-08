{
  description = "zno's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 最新 stable 分支的 nixpkgs，用于回退个别软件包的版本
    # 当前最新版本为 25.05
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-colors.url = "github:Misterio77/nix-colors";

    maple-mono = {
      url = "github:subframe7536/maple-font/variable";
      flake = false;
    };
    
    niri = {
      url = "github:sodiboo/niri-flake";
      #inputs.niri-unstable.follows = "niri-unstable";
    };
    
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # caelestia-shell = {
    #   url = "github:caelestia-dots/shell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    
    # caelestia-cli = {
    #   url = "github:caelestia-dots/cli";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    superfile.url = "github:yorukot/superfile";
    #vicinae.url = "github:vicinaehq/vicinae";
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
    daeuniverse.url = "github:daeuniverse/flake.nix";
  };

  outputs =
    { nixpkgs, self, nixpkgs-stable, nur, ... }@inputs:
    let
      username = "zno";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        # 为了拉取 chrome 等软件包，
        # 这里我们需要允许安装非自由软件
        config.allowUnfree = true;
      };
      # 集中管理所有外部 Flake 提供的 NixOS 模块
      # 这是一个包含所有外部依赖模块的列表
      externalModules = [
        # Adds the NUR overlay
        inputs.nur.modules.nixos.default
        # NUR modules to import
        inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya
        
        # ... 其他需要导入的 Flake 模块 ...
        # inputs.stylix.nixosModules.stylix
      ];
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/desktop ] ++ externalModules;
          specialArgs = {
            host = "desktop";
            inherit self inputs username pkgs-stable;
          };
        };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/laptop ] ++ externalModules;
          specialArgs = {
            host = "laptop";
            inherit self inputs username pkgs-stable;
          };
        };
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/vm ] ++ externalModules;
          specialArgs = {
            host = "vm";
            inherit self inputs username pkgs-stable;
          };
        };
      };
    };
}
