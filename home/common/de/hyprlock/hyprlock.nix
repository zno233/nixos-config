{
  config,
  inputs,
  ...
}:
let
  hyprlockConfig = "/home/zno/zno-config/home/common/de/hyprlock";
in
{
  programs.hyprlock = {
    enable = true;
  };

  xdg.configFile."hyprlock" = {
    source = config.lib.file.mkOutOfStoreSymlink "${hyprlockConfig}/.hyprlock";
    force = true;
  };

  xdg.configFile."hypr/hyprlock.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${hyprlockConfig}/hyprlock.conf";
  };

}
