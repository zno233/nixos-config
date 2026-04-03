{
  config,
  inputs,
  ...
}:
let
  hyprlockConfig = "${config.home.homeDirectory}/zno-config/home/common/de/hyprlock";
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
