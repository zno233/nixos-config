{ inputs, ... }:
{
  flake.modules.nixos.services-fs = {
    imports = with inputs.self.modules.nixos; [
      btrfs
    ];
  };
}
