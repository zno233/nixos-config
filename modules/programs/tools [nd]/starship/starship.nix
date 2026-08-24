{
  flake.modules.homeManager.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;

        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      xdg.configFile."starship.toml" = {
        source = ./starship.toml;
      };
    };
}
