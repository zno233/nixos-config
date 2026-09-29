{
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # 注意:settings 与此文件互斥,将来若改用 settings 需删掉本块。
    xdg.configFile."starship.toml" = {
      source = ./starship.toml;
    };
  };
}
