{ inputs, ... }:
{
  flake.modules.nixos.browsers = {
    imports = with inputs.self.modules.nixos; [
      brave
    ];
  };

  flake.modules.homeManager.browsers = {
    imports = with inputs.self.modules.homeManager; [
      zen
      # chrome
    ];
  };
}
