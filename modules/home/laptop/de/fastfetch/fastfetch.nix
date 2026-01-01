{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ fastfetch ];

  xdg.configFile."fastfetch/config.jsonc" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/modules/home/laptop/de/fastfetch/config.jsonc";
    force = true;
  };
  xdg.configFile."fastfetch/ascii".source = ./ascii;
  xdg.configFile."fastfetch/png".source = ./png;
}
