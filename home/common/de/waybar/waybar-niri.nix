{
  config,
  ...
}:
let
  waybarConfig = "/home/zno/zno-config/home/common/de/waybar";
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
