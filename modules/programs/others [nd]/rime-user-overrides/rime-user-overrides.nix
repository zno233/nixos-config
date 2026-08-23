{
  flake.modules.homeManager.rime-user-overrides =
    {
      config,
      ...
    }:
    {
      xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
        source = ./default.custom.yaml;
      };
      xdg.dataFile."fcitx5/rime/wanxiang.custom.yaml" = {
        source = ./wanxiang.custom.yaml;
      };
    };

}
