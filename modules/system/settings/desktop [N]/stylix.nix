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
        # 字体包（部分供备用或特殊软件调用）
        maple-mono-custom
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.caskaydia-cove
        nerd-fonts.symbols-only
        twemoji-color-font
        noto-fonts-color-emoji
        bibata-cursors
        # fantasque-sans-mono

        # 图标包
        # tela-circle-icon-theme

        # 备用的光标包
        # phinger-cursors
        # graphite-cursors
        # vimix-cursors
      ];

      # 最小化配置
      stylix = {
        enable = true;
        autoEnable = false;
        # enableReleaseChecks = false;
        image = ../../../../wallpapers/otherWallpaper/others/anime-girls-cat-girl-white-rose-nature-kawaii-skirt.jpg;
      };
    };
}
