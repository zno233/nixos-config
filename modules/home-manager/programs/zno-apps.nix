{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tsukimi                     #emby
    #tauon                       #local music player
    qbittorrent-enhanced        #bt
    telegram-desktop
    #cn
    wechat
    qq
    #windterm
    calibre
    vscode
    aria2
    android-studio 
    spotify
    wpsoffice-cn
    snipaste
    google-chrome
    #microsoft-edge 
    font-manager
    localsend
    maa-cli
  ];
}
