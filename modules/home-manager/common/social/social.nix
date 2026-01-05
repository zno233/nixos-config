{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # global
    telegram-desktop
    element-desktop
    # cn
    wechat
    qq
  ];
}
