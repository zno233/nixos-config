{ pkgs, ... }:
{
  home.packages = with pkgs; [
    telegram-desktop
    wechat
    qq
  ];
}
