{
  self,
  ...
}:
{
  flake-file.inputs = {
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
  };
  flake.modules.homeManager.zen =
    { inputs, pkgs, ... }:
    {
      imports = [ self.inputs.zen-browser.homeModules.beta ];

      programs.zen-browser.enable = true;
    };
}
