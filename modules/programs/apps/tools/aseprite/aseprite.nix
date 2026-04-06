{
  flake.modules.homeManager.aseprite =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.stable.aseprite
      ];
    };
}
