{ config, pkgs, ... }:
let
  glanceConfig = "${config.home.homeDirectory}/zno-config/home/common/tools/glance/glance.yml";
in
{
  home.packages = with pkgs; [
    glance # A self-hosted dashboard that puts all your feeds in one place
  ];

  xdg.configFile."glance/glance.yml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${glanceConfig}";
    # 关键选项：告诉 Home Manager 创建一个直接链接到源文件
    # 而不是先复制到 Store 再链接。
    force = true;
  };
}
