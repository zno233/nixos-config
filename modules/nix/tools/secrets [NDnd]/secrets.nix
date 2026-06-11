{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
      ];
      environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      age.secrets."deepseek-token" = {
        file = "${inputs.self}/secrets/deepseek-token.age";
        # 系统级解密后的文件默认所有者是 root，为了让用户 zno 读取，必须修改 owner
        owner = "zno";
        mode = "0400";
      };
    };

  flake.modules.darwin.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.agenix.darwinModules.default
      ];
      environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };

  flake.modules.homeManager.secrets =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
    };

}
