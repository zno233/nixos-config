{
  flake.modules.homeManager.gtk =
    { pkgs, config, ... }:
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.caskaydia-cove
        nerd-fonts.symbols-only
        twemoji-color-font
        noto-fonts-color-emoji
        fantasque-sans-mono
        maple-mono-custom
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
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 22;
        };
      };
      home.pointerCursor = {
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
