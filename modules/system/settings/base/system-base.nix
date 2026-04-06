{ inputs, ... }:
{
  flake.modules.nixos.system-base = {
    imports = with inputs.self.modules.nixos; [
      i18n
      network
      nh
      security
    ];
  };
}
