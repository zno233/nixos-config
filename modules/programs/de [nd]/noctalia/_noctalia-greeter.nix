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

  flake.modules.homeManager.noctalia-greeter =
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

        # Optional configuration
        greeter-args = "";
        # Full declarative greeter.toml (overwritten on each activation).
        # See examples/greeter.toml for every key (appearance.palette, output, …).
        settings = {
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
          keyboard = {
            layout = "us";
          };
        };
      };
    };
}
