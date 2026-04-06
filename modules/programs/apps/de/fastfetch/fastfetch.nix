{
  flake.modules.homeManager.fastfetch =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [ fastfetch ];

      xdg.configFile."fastfetch/config.jsonc" = {
        source = ./config.jsonc;
      };
      xdg.configFile."fastfetch/ascii".source = ./ascii;
      xdg.configFile."fastfetch/png".source = ./png;
    };
}
