{ config, ... }:
let
  configDir = config.flake.meta.mainUser.configDirectory;
in
{
  flake.modules.nixos.nh =
    { ... }:
    {
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 7d --keep 5";
        };
        flake = configDir;
      };
    };
}
