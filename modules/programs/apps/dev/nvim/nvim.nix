{
  flake.modules.homeManager.nvim =
    { config, pkgs, ... }:
    let
      lazyvimConfig = "${config.home.homeDirectory}/zno-config/modules/programs/apps/dev/nvim/lazyvim";
    in
    {
      programs.neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;
        package = pkgs.neovim-unwrapped;

        # defaultEditor = true; # set EDITOR at system-wide level
        viAlias = true;
        vimAlias = true;
      };

      xdg.configFile."nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${lazyvimConfig}";
        force = true;
      };
    };
}
