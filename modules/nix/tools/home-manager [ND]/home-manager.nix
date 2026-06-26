{
  inputs,
  config,
  ...
}:
let
  home-manager-config =
    { lib, pkgs-stable, ... }:
    {
      home-manager = {
        verbose = true;
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "hm-backup";
        backupCommand = "rm";
        overwriteBackup = true;
        extraSpecialArgs = {
          inherit pkgs-stable;
        };
      };
    };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };

}
