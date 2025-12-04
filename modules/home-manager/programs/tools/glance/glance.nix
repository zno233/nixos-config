{ pkgs, ... }:
{
  home.packages = with pkgs; [
    glance   #A self-hosted dashboard that puts all your feeds in one place
  ];
}
