{ inputs, ... }:
{
  flake.modules.homeManager.social = {
    imports = with inputs.self.modules.homeManager; [
      discord
      social-apps
    ];
  };
}
