{ 
  config,
  ...
}:
{
  programs.waybar = {
    enable = true;
  };

  xdg.configFile."waybar/config.jsonc" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/modules/home-manager/laptop/de/waybar/config.jsonc";
    force = true;
  };

  xdg.configFile."waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/modules/home-manager/laptop/de/waybar/style.css";
    force = true;
  };

  xdg.configFile."waybar/scripts".source = ./scripts;
  
}
