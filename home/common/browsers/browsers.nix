{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    #microsoft-edge
  ];
}
