{ inputs, ... }:
{
  flake.modules.homeManager.browsers = {
    imports = with inputs.self.modules.homeManager; [
      zen
      # chrome
    ];
  };
}
