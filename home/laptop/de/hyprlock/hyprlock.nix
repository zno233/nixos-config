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
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/home/laptop/de/hyprlock/.hyprlock";
    # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
    # 而不是先复制到 Store 再链接。
    force = true;
  };
 
}


