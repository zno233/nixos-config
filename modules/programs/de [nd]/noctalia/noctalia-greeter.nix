{
  self,
  lib,
  ...
}:
{
  flake.modules.nixos.noctalia-greeter =
    {
      pkgs,
      ...
    }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        extraArgs = [ ];

        settings = {
          # ── Session ──────────────────────────────────────────────────
          session.default = "niri";

          # ── User ─────────────────────────────────────────────────────
          user.default = "zno";

          # ── Appearance ───────────────────────────────────────────────
          appearance = {
            scheme = "Synced";
            theme_mode = "dark";
            password_style = "random";
            hide_logo = true;
            corner_radius_scale = 1.0;
            font_family = "Asuka Mono";
            # wallpaper = {
            #   path = "~/Pictures/wallpapers/others/26.02.14.jpg";
            #   fill_mode = "crop";
            # };
          };

          # ── Cursor ───────────────────────────────────────────────────
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 22;
            path = "${pkgs.bibata-cursors}/share/icons";
          };

          # ── Keyboard ─────────────────────────────────────────────────
          keyboard = {
            layout = "us";
            numlock = true;
          };

          # ── Idle ─────────────────────────────────────────────────────
          idle.timeout = 300;
        };
      };
    };
}
