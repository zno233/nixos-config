{ pkgs, config, ... }:
let
  fastfetchConfig = "${config.home.homeDirectory}/zno-config/home/common/de/fastfetch/config.jsonc";
in
{
  home.packages = with pkgs; [ fastfetch ];

  xdg.configFile."fastfetch/config.jsonc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${fastfetchConfig}";
    force = true;
  };
  xdg.configFile."fastfetch/ascii".source = ./ascii;
  xdg.configFile."fastfetch/png".source = ./png;
}
