{
  flake.modules.homeManager.aseprite =
    { pkgs, pkgs-stable, ... }:
    {
      home.packages = [
        pkgs-stable.aseprite
      ];
    };
}
