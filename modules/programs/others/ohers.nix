{ inputs, ... }:
{
  flake.modules.homeManager.others = {
    imports = with inputs.self.modules.homeManager; [
      rime-user-overrides
    ];
  };
}
