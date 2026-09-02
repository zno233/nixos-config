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

  flake.modules.nixos.stylix =
    { pkgs, ... }:
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      environment.systemPackages = with pkgs; [
        # 光标
        bibata-cursors
      ];

      # 最小化配置
      stylix = {
        enable = true;
        autoEnable = false;
        # enableReleaseChecks = false;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
        polarity = "dark";
      };
    };
}
