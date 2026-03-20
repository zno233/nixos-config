{
  config,
  ...
}:
{
  xdg.dataFile."fcitx5/rime/default.custom.yaml"= {
    source = config.lib.file.mkOutOfStoreSymlink ./rime-user-overrides/default.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/wanxiang-lts-zh-hans.gram"= {
    source = config.lib.file.mkOutOfStoreSymlink ./rime-user-overrides/wanxiang-lts-zh-hans.gram;
    force = true;
  };
}