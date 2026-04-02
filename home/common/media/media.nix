{ pkgs, ... }:
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

    stable.fooyin # like fb2k
    #spotify
    mpv
    mpv-handler
    splayer
    kazumi # anime online
    tsukimi # emby
    #tauon                       #local music player
    gapless
  ];
}
