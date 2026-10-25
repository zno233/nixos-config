{
  flake.modules.nixos.fprintd =
    { pkgs, ... }:
    {
      services.fprintd.enable = true;
    };
}
