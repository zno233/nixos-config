{ pkgs, inputs, ... }:
{
  nixpkgs = {
    overlays = [
      (
        final: prev:
        (import ../../pkgs {
          inherit inputs;
          inherit pkgs;
          inherit (prev) system;
        })
      )

      # 加入 CachyOS kernel overlay
      inputs.nix-cachyos-kernel.overlay
      
      inputs.nur.overlays.default
      inputs.niri.overlays.niri
    ];
  };
}
