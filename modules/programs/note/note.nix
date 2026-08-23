{ inputs, ... }:
{
  flake.modules.homeManager.note = {
    imports = with inputs.self.modules.homeManager; [
      obsidian
    ];
  };
}
