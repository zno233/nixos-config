{
  config,
  ...
}:
let
  rimeOverrides = "${config.home.homeDirectory}/zno-config/home/common/others/rime-user-overrides/rime-user-overrides";
in
{
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${rimeOverrides}/default.custom.yaml";
    force = true;
  };
}
