{ pkgs, ... }:
{
  home.packages = with pkgs; [
    telegram-desktop
    element-desktop
    wechat
    qq
  ];
}
