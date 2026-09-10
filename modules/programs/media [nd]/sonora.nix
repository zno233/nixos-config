{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    sonora = {
      url = "github:sonorahq/sonora";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.sonora =
    {
      ...
    }:
    {
      imports = [
        inputs.sonora.homeManagerModules.default
      ];

      programs.sonora = {
        enable = true;
        settings = {
          appearance.theme = "dark";
        };
      };
    };
}
