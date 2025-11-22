{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
    android-studio 
  ];
}
