{
  flake.modules.homeManager.helix =
    { lib, pkgs, ... }:
    {
      programs.helix = {
        enable = true;
        settings = {
          theme = "everforest_dark";
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.nixfmt;
          }
        ];
        themes = {
          autumn_night_transparent = {
            "inherits" = "autumn_night";
            "ui.background" = { };
          };
        };
      };
    };
}
