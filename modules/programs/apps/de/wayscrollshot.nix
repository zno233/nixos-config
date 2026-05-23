{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    wayscrollshot = {
      url = "github:jswysnemc/wayscrollshot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules.homeManager.wayscrollshot =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          # 一个用于 Wayland 的滚动截图工具，在滚动时实时捕获并拼接图像
          inputs.wayscrollshot.packages.${stdenv.hostPlatform.system}.default
        ];
      };
    };
}
