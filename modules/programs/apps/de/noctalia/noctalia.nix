{
  self,
  ...
}:
{
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.noctalia =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    let
      noctaliaConfig = "${config.home.homeDirectory}/zno-config/modules/programs/apps/de/noctalia/.noctalia";
    in
    {
      imports = [
        self.inputs.noctalia.homeModules.default
      ];

      home.packages = [
        pkgs.qt6Packages.qt6ct # for icon theme
        pkgs.app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
      ];

      programs.noctalia-shell = {
        enable = true;
      };
    };
}
