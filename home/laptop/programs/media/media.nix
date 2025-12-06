{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    pkgs.tsukimi
    pkgs-stable.fooyin # like fb2k
    pkgs.spotify
    pkgs.mpv
    pkgs.splayer
  ];
}
