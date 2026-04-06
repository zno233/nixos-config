{
  self,
  ...
}:
{
  flake-file.inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  flake.modules.nixos.flatpak =
    { inputs, ... }:
    {
      imports = [ self.inputs.nix-flatpak.nixosModules.nix-flatpak ];

      services.flatpak = {
        enable = true;
        packages = [
          "com.github.tchx84.Flatseal"
        ];
        overrides = {
          global = {
            # Force Wayland by default
            Context.sockets = [
              "wayland"
              "!x11"
              "!fallback-x11"
            ];
          };
        };
      };
    };
}
