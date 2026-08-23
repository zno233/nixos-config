{ inputs, ... }:
{
  flake.modules.nixos.game = {
    imports = with inputs.self.modules.nixos; [
      steam
    ];
  };

  flake.modules.homeManager.game = {
    imports = with inputs.self.modules.homeManager; [
      gaming
    ];
  };
}
