{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qbittorrent-enhanced        #bt
    #windterm
    calibre
    aria2
    snipaste
    font-manager
    localsend
  ];
}
