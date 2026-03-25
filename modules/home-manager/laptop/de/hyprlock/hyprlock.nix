{
  config,
  inputs,
  ...
}:
let
  hyprlockConfig = "/home/zno/zno-config/modules/home-manager/laptop/de/hyprlock/hyprlock.conf";
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
    source = config.lib.file.mkOutOfStoreSymlink "${hyprlockConfig}";
  };

}
