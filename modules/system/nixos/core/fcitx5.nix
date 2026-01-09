{ pkgs, inputs, ... }:

{
  # ------------------------------------------------------------------------
  # 输入法配置 (Fcitx5)
  # ------------------------------------------------------------------------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-rime
      rime-data
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      fcitx5-lua
    ];
  };
  
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx5";
  };
  
  #修复fcitx在某些软件的显示问题
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
}

