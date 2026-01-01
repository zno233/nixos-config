{ pkgs, pkgs-stable, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    audacity
    gimp
    media-downloader
    obs-studio
    pavucontrol
    soundwireserver
    video-trimmer
    vlc
    
    fooyin # like fb2k
    #spotify
    mpv
    splayer
    kazumi  #anime online
    tsukimi                    #emby 
    #tauon                       #local music player
  ];
}
