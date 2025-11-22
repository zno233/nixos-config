{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    settings.monitor = [ ",2520x1680@120,auto,1.5" ];#1.5原本是auto

    extraConfig = ''
      # hyprlang noerror true
        source = ~/.config/hypr/monitors.conf
        source = ~/.config/hypr/workspaces.conf
      # hyprlang noerror false
    '';
  };

  home.packages = with pkgs; [ nwg-displays ];
}
