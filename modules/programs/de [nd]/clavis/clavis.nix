{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    clavis = {
      url = "github:zno233/clavis-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.clavis = {
    imports = [
      inputs.clavis.homeManagerModules.default
    ];

    programs.clavis = {
      enable = true;
      # shell = true;
      # clipboard = true;
      # compositorUnit = "niri.service";
    };
  };
}
