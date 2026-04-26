{
  inputs,
  ...
}:
{
  # default settings needed for all nixosConfigurations

  flake.modules.nixos.system-minimal =
    { pkgs, ... }:
    {
      imports = [
        inputs.nur.modules.nixos.default
      ];
      nixpkgs = {
        # Android sdk license
        config.android_sdk.accept_license = true;
        overlays = [
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              localSystem = prev.stdenv.hostPlatform;
              config.allowUnfree = true;
            };
          })

          # inputs.lix-module.overlays.default
          (final: prev: {
            inherit (prev.lixPackageSets.stable)
              nixpkgs-review
              nix-eval-jobs
              nix-fast-build
              colmena
              ;
          })

          # pkgs
          (
            final: prev:
            (import ../../../../../pkgs {
              inherit inputs;
              pkgs = final;
              hostPlatform = final.stdenv.hostPlatform;
            })
          )

          # 加入 CachyOS kernel overlay
          inputs.nix-cachyos-kernel.overlays.pinned

          inputs.nur.overlays.default

          inputs.niri.overlays.niri

          # inputs.stylix.nixosModules.stylix
        ];
      };
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "25.05";

      nix.settings = {
        auto-optimise-store = true;
        substituters = [
          # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org"
          # "https://hyprland.cachix.org"
          "https://ghostty.cachix.org"
          # "https://vicinae.cachix.org"
          "https://niri.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
          "https://attic.xuyh0120.win/lantian"
          "https://cache.lix.systems"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
          # "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        ];

        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operator"
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      nix.extraOptions = ''
        warn-dirty = false
        keep-outputs = true
      '';

      nix.package = pkgs.lixPackageSets.stable.lix;

    };
}
