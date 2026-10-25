{
  flake.modules.homeManager.gtk =
    { pkgs, config, ... }:
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        # 光标
        bibata-cursors
        phinger-cursors
        graphite-cursors
        vimix-cursors
      ];

      gtk = {
        enable = true;
        theme = {
          name = "Graphite-Dark";
          package = pkgs.graphite-gtk-theme.override {
            tweaks = [
              "rimless"
              "black"
            ]; # black 让底色更纯粹
          };
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme.override { color = "green"; };
        };
        cursorTheme = {
          enable = true;
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 22;
        };
      };
      home.pointerCursor = {
        enable = true;
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 22;
      };
      xdg.configFile."gtk-4.0/gtk.css" = {
        force = true;
        # source = ./gtk.css;
      };
      xdg.configFile."gtk-4.0/settings.ini" = {
        force = true;
      };
    };
}
