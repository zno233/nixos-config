{
  self,
  ...
}:
{
  flake-file.inputs = {
    inir.url = "github:snowarch/iNiR";
  };

  flake.modules.homeManager.inir =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [
        self.inputs.inir.homeModules.default
      ];

      home.packages = with pkgs; [
        # niri
        # foot
        # fuzzel
        # wlsunset
        # brightnessctl
        # playerctl
        # grim
        # slurp
        # swappy
      ];

      programs.inir = {
        enable = true;
        service.compositor = "niri";
        extraPackages = [ config.programs.niri.package ];
      };
    };
}
