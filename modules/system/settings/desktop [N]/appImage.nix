{
  flake.modules.nixos.appImage =
    { inputs, ... }:
    {
      programs.appimage.enable = true;
      programs.appimage.binfmt = true;
    };
}
