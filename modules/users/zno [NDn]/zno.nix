{
  self,
  lib,
  ...
}:
{
  config = {
    flake.modules = lib.mkMerge [
      (self.factory.user "zno" true)
      {
        nixos.zno = {
          imports = with self.modules.nixos; [
            # developmentEnvironment
          ];
          users.users.zno = {
            group = "users";
            extraGroups = [
              "networkmanager"
              "video"
              "audio"
            ];
          };
        };
        darwin.zno = {
          imports = with self.modules.darwin; [
            # drawingApps
            # developmentEnvironment
          ];
        };
        homeManager.zno =
          { pkgs, ... }:
          {
            imports = with self.modules.homeManager; [
              system-desktop
              # adminTools
              # vscode
              # passwordManager
            ];
            home.packages = with pkgs; [
              mediainfo
            ];
          };
      }
    ];
  };
}
