{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tsukimi                     #emby
    fooyin                     #like FB2K
    spotify
    mpv
  ];
}
