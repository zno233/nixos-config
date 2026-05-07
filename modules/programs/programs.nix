{ inputs, ... }:
{
  flake.modules.homeManager.programs = {
    imports = with inputs.self.modules.homeManager; [
      ai
      browsers # based browser
      de
      dev
      media
      note
      office
      scripts
      social
      others
      tools
      gaming # packages related to gaming
    ];
  };
}
