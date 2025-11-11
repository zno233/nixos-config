{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #microsoft-edge 
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
    fooyin                     #like FB2K
    android-studio 
    spotify
    wpsoffice-cn
    snipaste
    google-chrome
    font-manager
  ];
}
