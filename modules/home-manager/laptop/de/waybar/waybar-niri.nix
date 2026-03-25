{
  config,
  ...
}:
let
  waybarConfig = "/home/zno/zno-config/modules/home-manager/laptop/de/waybar/config.jsonc";
in
{
  programs.waybar = {
    enable = true;
  };

  xdg.configFile."waybar/config.jsonc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${waybarConfig}/config.jsonc";
    force = true;
  };

  xdg.configFile."waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${waybarConfig}/style.css";
    force = true;
  };

  xdg.configFile."waybar/scripts".source = ./scripts;

}
