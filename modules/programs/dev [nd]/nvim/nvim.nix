{
  self,
  ...
}:
{
  flake-file.inputs = {
    lazyvim-nix = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.nvim =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.inputs.lazyvim-nix.homeManagerModules.default
      ];

      programs.lazyvim = {
        enable = true;
        configFiles = ./lazyvim;
      };
    };
}
