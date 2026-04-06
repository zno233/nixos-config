{
  flake.modules.homeManager.nvim =
    { config, pkgs, ... }:
    let
      lazyvimConfig = "${config.home.homeDirectory}/zno-config/modules/programs/apps/dev/nvim/lazyvim";
    in
    {
      programs.neovim = {
        enable = true;
        package = pkgs.neovim-unwrapped;

        # defaultEditor = true; # set EDITOR at system-wide level
        viAlias = true;
        vimAlias = true;
      };

      xdg.configFile."nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${lazyvimConfig}";
        # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
        # 而不是先复制到 Store 再链接。
        force = true;
      };
    };
}
