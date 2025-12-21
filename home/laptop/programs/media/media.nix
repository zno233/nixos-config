{ pkgs, pkgs-stable, ... }:
{
  home.packages = with pkgs; [
    tsukimi
    fooyin # like fb2k
    #spotify
    mpv
    splayer
    kazumi  #anime online
  ];
}
