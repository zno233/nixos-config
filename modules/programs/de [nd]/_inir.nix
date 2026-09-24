{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    inir = {
      url = "github:snowarch/iNiR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.inir =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.inir.homeModules.inir
      ];

      programs.inir = {
        enable = true;
        service.compositor = "niri";
        # service.compositor = null; # no auto-start wiring; start manually with: systemctl --user start inir.service

        # extraPackages lands on the service PATH. The iNiR package already wraps
        # its own runtime deps (foot, fuzzel, grim, slurp, swappy, brightnessctl,
        # wlsunset, playerctl, wl-clipboard, cliphist, …) — do not duplicate them
        # here. `niri` is not wrapped, so pass the compositor's package so
        # features calling `niri msg` match the session.
        extraPackages = [
          config.programs.niri.package
          # pkgs.easyeffects # opt-in: native iNiR equalizer (verifies LSP plugin at runtime)
        ];

        # Opt-in: expose the packaged shell at ~/.config/quickshell/inir for tools
        # that expect the traditional path (conflicts with an existing checkout there).
        # configSymlink.enable = true;

        # Optional mascot art pack:
        # package = inputs.inir.packages.${pkgs.system}.inir-with-mascot;
      };
    };
}
