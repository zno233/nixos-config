{ pkgs, inputs, config, ... }:
{
  nixpkgs = {
    # Android sdk liscense
    config.android_sdk.accept_license = true;

    overlays = [
      # inputs.lix-module.overlays.default

      (final: prev: {
        inherit (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena;
      })

      (
        final: prev:
        (import ../../pkgs {
          inherit inputs;
          pkgs = final;
          hostPlatform = final.stdenv.hostPlatform;
        })
      )

      # 加入 CachyOS kernel overlay
      inputs.nix-cachyos-kernel.overlays.pinned
      
      inputs.nur.overlays.default
      inputs.niri.overlays.niri
    ];
  };
  nix.package = pkgs.lixPackageSets.stable.lix;
}
