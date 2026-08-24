{
  self,
  lib,
  ...
}:
{
  flake-file.inputs = {
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.noctalia-greeter =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      programs.noctalia-greeter = {
        enable = true;

        greeter-args = "";

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
            hide_logo = false;
            corner_radius_scale = 1.0;
            font_family = "Maple Mono NF";
          };

          # ── Palette (Gruvbox Material Dark Medium) ──────────────────
          appearance.palette = {
            primary = "#d8ca36";
            on_primary = "#1d2021";
            secondary = "#a6accd";
            on_secondary = "#1d2021";
            tertiary = "#8ec07c";
            on_tertiary = "#1d2021";
            error = "#fb4934";
            on_error = "#1d2021";
            surface = "#282828";
            on_surface = "#d4d4d4";
            surface_variant = "#3c3836";
            on_surface_variant = "#bdae93";
            outline = "#504945";
            shadow = "#1d2021";
            hover = "#8ec07c";
            on_hover = "#1d2021";
          };

          # ── Cursor ───────────────────────────────────────────────────
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
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
