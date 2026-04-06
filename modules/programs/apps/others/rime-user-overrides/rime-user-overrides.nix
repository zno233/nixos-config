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
    };

}
