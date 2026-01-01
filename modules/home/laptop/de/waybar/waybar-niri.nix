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
      "/home/zno/zno-config/modules/home/laptop/de/waybar/config.jsonc";
    # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
    # 而不是先复制到 Store 再链接。
    force = true;
  };

  xdg.configFile."waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/modules/home/laptop/de/waybar/style.css";
    # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
    # 而不是先复制到 Store 再链接。
    force = true;
  };

  xdg.configFile."waybar/scripts".source = ./scripts;
  
}
