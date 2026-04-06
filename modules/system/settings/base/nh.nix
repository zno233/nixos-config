{ config, ... }:
let
  configDir = config.flake.meta.users.zno.configDirectory;
in
{
  flake.modules.nixos.nh =
    { config, ... }:
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
