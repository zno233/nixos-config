{
  inputs,
  ...
}:
{
  # default settings needed for all nixosConfigurations

  flake.modules.nixos.system-minimal =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nur.modules.nixos.default
      ];

      nixpkgs = {
        # Android sdk license
        config.android_sdk.accept_license = true;
        overlays = [
          # # add nixpkgs-stable overlay
          # (final: prev: {
          #   stable = import inputs.nixpkgs-stable {
          #     inherit (prev.stdenv.hostPlatform) system;
          #     config.allowUnfree = true;
          #   };
          # })

          # lix — https://lix.systems/add-to-config
          # (final: prev: {
          #   inherit (prev.lixPackageSets.stable)
          #     nixpkgs-review
          #     nix-eval-jobs
          #     nix-fast-build
          #     colmena
          #     ;
          # })

          # nix-packages — personal packages
          inputs.nix-packages.overlays.default

          # pkgs
          (
            final: prev:
            (import ../../../../../pkgs {
              inherit inputs;
              pkgs = final;
              hostPlatform = final.stdenv.hostPlatform;
            })
          )
        ];
      };
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "26.05";

      nix.settings = {
        auto-optimise-store = true;
        substituters = [
          # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          # "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.cernet.edu.cn/nix-channels/store?priority=30"
          "https://cache.nixos.org?priority=40"
          "https://nix-community.cachix.org?priority=50"
          "https://install.determinate.systems?priority=50"
          # "https://nix-gaming.cachix.org"
          # "https://hyprland.cachix.org"
          # "https://ghostty.cachix.org"
          # "https://vicinae.cachix.org"
          "https://niri-epireyn.cachix.org?priority=60"
          # "https://noctalia.cachix.org"
          # "https://nixpkgs-wayland.cachix.org"
          "https://cache.lantian.pub/lantian?priority=70"
          # "https://cache.lix.systems?priority=50"
          "https://cache.numtide.com?priority=50"
          # "https://zed.cachix.org"
          # "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM"
          # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          # "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
          # "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
          "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="
          # "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
          # "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          # "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
          # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];

        experimental-features = [
          "nix-command"
          "flakes"
          # "pipe-operator"
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      nix.extraOptions = ''
        warn-dirty = false
      '';

      # Determinate's nixos module sets nix.package itself (priority 750).
      # A plain `nix.package` set here (priority 100) would override it and
      # make det-nixd daemonize lix by mistake — never set both.
      # nix.package = pkgs.lixPackageSets.stable.lix;

    };
}
