{
  self,
  ...
}:
{
  flake-file.inputs = {
    mark-shot = {
      url = "github:jswysnemc/mark-shot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.mark-shot =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        self.inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
