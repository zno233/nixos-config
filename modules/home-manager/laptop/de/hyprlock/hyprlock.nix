{
  config,
  inputs,
  ...
}:
{
  programs.hyprlock = {
    enable = true;
  };

  xdg.configFile."hyprlock" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/zno/zno-config/modules/home-manager/laptop/de/hyprlock/.hyprlock";
    force = true;
  };

  xdg.configFile."hypr/hyprlock.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/zno/zno-config/modules/home-manager/laptop/de/hyprlock/hyprlock.conf";
    force = true;
  };

}
