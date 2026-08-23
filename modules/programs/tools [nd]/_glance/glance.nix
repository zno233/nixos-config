{
  flake.modules.homeManager.glance =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        glance # A self-hosted dashboard that puts all your feeds in one place
      ];

      xdg.configFile."glance/glance.yml" = {
        source = ./glance.yml;
      };
    };
}
