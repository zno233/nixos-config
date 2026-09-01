{ inputs, ... }:
{
  flake.modules.nixos.game = {
    imports = with inputs.self.modules.nixos; [
      steam
      game-performance
    ];
  };

  flake.modules.homeManager.game = {
    imports = with inputs.self.modules.homeManager; [
      gaming
    ];
  };
}
