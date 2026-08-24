{ inputs, ... }:
{
  flake.modules.nixos.programs = {
    imports = with inputs.self.modules.nixos; [
      browsers # based browser
      de
      game
      tools
      others
    ];
  };

  flake.modules.homeManager.programs = {
    imports = with inputs.self.modules.homeManager; [
      ai
      browsers # based browser
      de
      dev
      game
      media
      note
      office
      scripts
      social
      others
      tools
    ];
  };
}
