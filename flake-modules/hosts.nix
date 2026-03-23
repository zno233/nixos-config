{ inputs, ... }:

let
  userName = "zno";
  system = "x86_64-linux";

  # 全局核心模組
  coreModules = [
    { nixpkgs.config.allowUnfree = true; }

    # nixpkgs-stable overlay
    (
      { config, ... }:
      {
        nixpkgs.overlays = [
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              localSystem = prev.stdenv.hostPlatform;
              config.allowUnfree = true;
            };
          })
        ];
      }
    )

    inputs.nix-index-database.nixosModules.nix-index
    inputs.nur.modules.nixos.default
    # inputs.stylix.nixosModules.stylix
  ];

  # 可重用 mkHost
  mkHost =
    {
      hostName,
      extraModules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        self = inputs.self; # 方便 host 裡引用 self.packages 等
        meta = {
          inherit userName system hostName;
        };
      };

      modules =
        coreModules
        ++ [
          ../hosts/${hostName}
        ]
        ++ extraModules;
    };

in
{
  flake = {
    nixosConfigurations = {
      desktop = mkHost {
        hostName = "desktop";
        extraModules = [
          # inputs.nix-gaming.nixosModules.default
          # inputs.nix-flatpak.nixosModules.nix-flatpak
          # inputs.niri.nixosModules.default
        ];
      };

      laptop = mkHost {
        hostName = "laptop";
      };

      vm = mkHost {
        hostName = "vm";
      };
    };
  };
}
