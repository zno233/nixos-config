{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.stylix = {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];

    # 最小化配置
    stylix = {
      enable = true;
      autoEnable = false;
      enableReleaseChecks = false;
      image = ../../../../wallpapers/otherWallpaper/others/anime-girls-cat-girl-white-rose-nature-kawaii-skirt.jpg;
    };
  };
}
