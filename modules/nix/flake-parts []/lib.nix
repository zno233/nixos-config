{
  inputs,
  lib,
  ...
}:
# 定义一个通用的生成器
# pkgsInput 是从 inputs 中传入的特定频道（如 inputs.nixpkgs-stable）
let
  mkSpecialArgs = pkgsInput: system: {
    inherit inputs;
    pkgs-stable = import pkgsInput {
      inherit system;
      config.allowUnfree = true;
    };
  };
in
{
  # Helper functions for creating system / home-manager configurations

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {

    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = mkSpecialArgs inputs.nixpkgs-stable system;
        modules = [
          inputs.self.modules.nixos.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };

    mkDarwin = system: name: {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          inputs.self.modules.darwin.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };

    mkHomeManager = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        modules = [
          inputs.self.modules.homeManager.${name}
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
          }
        ];
      };
    };

  };
}
