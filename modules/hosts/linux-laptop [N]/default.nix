{
  flake.modules.nixos.linux-laptop =
    {
      ...
    }:
    {
      imports = [
        ./_hardware-configuration.nix
      ];
    };
}
