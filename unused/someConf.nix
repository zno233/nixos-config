{ config, pkgs, ... }:

{
  # 使用 xdg.configFile 管理配置文件
  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "mpv/mpv.conf".source = ./mpv/mpv.conf;
    # 假设你的 fcitx5 配置文件是 rime 字典
    "rime/custom_phrase.txt".source = ./rime/custom_phrase.txt;
  };

  # 使用 home.file 管理不遵循 XDG 的文件或脚本
  home.file.".local/bin/my-script.sh" = {
    source = ./scripts/my-script.sh;
    executable = true; # 别忘了设置可执行权限
  };
}
